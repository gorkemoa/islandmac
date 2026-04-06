import Foundation
import Combine
import EventKit

class CalendarService: ObservableObject {
    private let eventStore = EKEventStore()

    @Published var upcomingEvents: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var todayEventCount: Int = 0

    private var refreshTimer: Timer?

    init() {
        checkAuthorization()
        // Takvim değişiklik bildirimi
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(calendarChanged),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Yetkilendirme

    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        self.authorizationStatus = status

        if #available(macOS 14.0, *) {
            if status == .fullAccess { fetchEvents() }
        } else {
            if status == .authorized { fetchEvents() }
        }
    }

    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, _ in
                DispatchQueue.main.async {
                    if granted { self?.fetchEvents() }
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    if granted { self?.fetchEvents() }
                    completion(granted)
                }
            }
        }
    }

    // MARK: - Etkinlik Getirme

    func fetchEvents() {
        let now      = Date()
        let endOfDay = Calendar.current.date(byAdding: .hour, value: 24, to: now) ?? now

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endOfDay,
            calendars: eventStore.calendars(for: .event)
        )

        let events = eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }

        DispatchQueue.main.async {
            self.upcomingEvents  = events
            self.todayEventCount = events.count
        }
    }

    @objc private func calendarChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchEvents()
        }
    }

    // MARK: - Yardımcılar

    /// Sıradaki toplantıya kaç dakika var
    var minutesToNextEvent: Int? {
        guard let next = upcomingEvents.first else { return nil }
        let diff = next.startDate.timeIntervalSinceNow
        guard diff > 0 else { return nil }
        return Int(diff / 60)
    }
}

