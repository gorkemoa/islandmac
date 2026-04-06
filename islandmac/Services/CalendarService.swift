import Foundation
import EventKit
import Combine

enum MeetingPlatform: String {
    case zoom = "Zoom"
    case meet = "Google Meet"
    case teams = "Teams"
    case webex = "Webex"
    case facetime = "FaceTime"
    case unknown = "Takvim"

    var icon: String {
        switch self {
        case .zoom: return "video"
        case .meet: return "video.badge.checkmark"
        case .teams: return "person.2.wave.2"
        case .webex: return "rectangle.connected.to.line.below"
        case .facetime: return "video.bubble.left"
        case .unknown: return "calendar"
        }
    }
}

@MainActor
final class CalendarService: NSObject, ObservableObject {
    @Published private(set) var upcomingEvents: [EKEvent] = []
    @Published private(set) var currentEvent: EKEvent?
    @Published private(set) var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published private(set) var todayEventCount: Int = 0
    @Published private(set) var nextFreeWindowText: String = "Takvim izni bekleniyor"
    @Published private(set) var densityText: String = "Henüz hesaplanmadı"

    private let eventStore = EKEventStore()
    private var refreshTimer: Timer?

    override init() {
        super.init()
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        observeCalendarChanges()
        if hasCalendarAccess {
            refresh()
            startRefreshTimer()
        }
    }

    deinit {
        refreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    var hasCalendarAccess: Bool {
        if #available(macOS 14.0, *) {
            return authorizationStatus == .fullAccess
        }
        return authorizationStatus == .authorized
    }

    var nextEvent: EKEvent? {
        upcomingEvents.first(where: { $0.endDate > .now })
    }

    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, _ in
                Task { @MainActor in
                    self?.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    if granted {
                        self?.refresh()
                        self?.startRefreshTimer()
                    }
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                Task { @MainActor in
                    self?.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                    if granted {
                        self?.refresh()
                        self?.startRefreshTimer()
                    }
                    completion(granted)
                }
            }
        }
    }

    func refresh() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        guard hasCalendarAccess else {
            upcomingEvents = []
            currentEvent = nil
            todayEventCount = 0
            nextFreeWindowText = "İzin verilmedi"
            densityText = "Takvim kapalı"
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? .now
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: eventStore.calendars(for: .event)
        )

        let allTodayEvents = eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        currentEvent = allTodayEvents.first(where: { $0.startDate <= .now && $0.endDate > .now })
        upcomingEvents = allTodayEvents.filter { $0.endDate > .now }
        todayEventCount = allTodayEvents.count
        densityText = buildDensityText(allTodayEvents)
        nextFreeWindowText = buildFreeWindowText(allTodayEvents)
    }

    func minutesToEvent(_ event: EKEvent) -> Int? {
        let diff = event.startDate.timeIntervalSinceNow
        guard diff > 0 else { return nil }
        return Int(diff / 60)
    }

    func joinURL(for event: EKEvent) -> URL? {
        if let eventURL = event.url {
            return eventURL
        }

        let candidates = [event.location, event.notes]
            .compactMap { $0 }
            .joined(separator: "\n")

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }

        let range = NSRange(candidates.startIndex..<candidates.endIndex, in: candidates)
        return detector.matches(in: candidates, options: [], range: range)
            .compactMap(\.url)
            .first
    }

    func platform(for event: EKEvent) -> MeetingPlatform {
        let searchable = [
            event.url?.absoluteString,
            event.location,
            event.notes,
            event.title
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")

        if searchable.contains("zoom") { return .zoom }
        if searchable.contains("meet.google") || searchable.contains("google meet") { return .meet }
        if searchable.contains("teams") || searchable.contains("microsoft.com") { return .teams }
        if searchable.contains("webex") { return .webex }
        if searchable.contains("facetime") { return .facetime }
        return .unknown
    }

    private func observeCalendarChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(calendarChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }

    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        refreshTimer?.tolerance = 12
    }

    @objc private func calendarChanged() {
        Task { @MainActor in
            refresh()
        }
    }

    private func buildDensityText(_ events: [EKEvent]) -> String {
        let totalMinutes = events.reduce(0) { partial, event in
            partial + Int(event.endDate.timeIntervalSince(event.startDate) / 60)
        }

        switch totalMinutes {
        case 0:
            return "Takvim ferah"
        case 1..<120:
            return "Yoğunluk düşük"
        case 120..<300:
            return "Gün dengeli"
        case 300..<480:
            return "Yoğun tempo"
        default:
            return "Takvim dolu"
        }
    }

    private func buildFreeWindowText(_ events: [EKEvent]) -> String {
        guard events.isEmpty == false else {
            return "Tüm gün uygun görünüyorsun"
        }

        let now = Date()
        let calendar = Calendar.current
        let workdayEnd = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now

        var cursor = now
        for event in events where event.endDate > now {
            if event.startDate.timeIntervalSince(cursor) >= 30 * 60 {
                return "Önünde \(formatInterval(from: cursor, to: event.startDate)) boş alan var"
            }
            cursor = max(cursor, event.endDate)
        }

        if workdayEnd.timeIntervalSince(cursor) >= 30 * 60 {
            return "Günün kalanında \(formatInterval(from: cursor, to: workdayEnd)) müsaitsin"
        }

        return "Boş alan daraldı"
    }

    private func formatInterval(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}
