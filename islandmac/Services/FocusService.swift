import Foundation
import UserNotifications

enum FocusState: String {
    case idle = "Hazır"
    case work = "Derin Çalışma"
    case breakTime = "Mola"
}

@MainActor
final class FocusService: ObservableObject {
    @Published private(set) var currentState: FocusState = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var totalFocusMinutesToday: Int = 0
    @Published private(set) var sessionProgress: Double = 0
    @Published private(set) var activeSessionTitle: String = "Odak yok"

    private let defaults = UserDefaults.standard
    private var timer: Timer?
    private var sessionTotalSeconds = 0

    init() {
        totalFocusMinutesToday = defaults.integer(forKey: "focus.totalMinutesToday")
        resetIfNeededForNewDay()
    }

    deinit {
        timer?.invalidate()
    }

    func startFocus(minutes: Int) {
        startSession(title: "\(minutes) dk derin çalışma", minutes: minutes, state: .work)
    }

    func startBreak(minutes: Int) {
        startSession(title: "\(minutes) dk mola", minutes: minutes, state: .breakTime)
    }

    func stop() {
        if currentState == .work {
            let elapsed = sessionTotalSeconds - remainingSeconds
            totalFocusMinutesToday += max(elapsed / 60, 0)
            defaults.set(totalFocusMinutesToday, forKey: "focus.totalMinutesToday")
        }

        timer?.invalidate()
        timer = nil
        sessionTotalSeconds = 0
        remainingSeconds = 0
        sessionProgress = 0
        activeSessionTitle = "Odak yok"
        currentState = .idle
    }

    func formatTime() -> String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startSession(title: String, minutes: Int, state: FocusState) {
        timer?.invalidate()
        sessionTotalSeconds = max(minutes * 60, 60)
        remainingSeconds = sessionTotalSeconds
        sessionProgress = 0
        activeSessionTitle = title
        currentState = state

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        timer?.tolerance = 0.2
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            completeSession()
            return
        }

        remainingSeconds -= 1
        let elapsed = sessionTotalSeconds - remainingSeconds
        sessionProgress = min(max(Double(elapsed) / Double(max(sessionTotalSeconds, 1)), 0), 1)
    }

    private func completeSession() {
        timer?.invalidate()
        timer = nil

        if currentState == .work {
            totalFocusMinutesToday += sessionTotalSeconds / 60
            defaults.set(totalFocusMinutesToday, forKey: "focus.totalMinutesToday")
            requestNotificationPermissionIfNeeded()
            sendCompletionNotification()
        }

        currentState = .idle
        sessionProgress = 1
        remainingSeconds = 0
        activeSessionTitle = "Oturum tamamlandı"
    }

    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }

    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Odak oturumu tamamlandı"
        content.body = "Bir blok daha bitti. Şimdi mola verebilir veya yeni oturum başlatabilirsin."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func resetIfNeededForNewDay() {
        let key = "focus.lastResetDay"
        let today = Calendar.current.startOfDay(for: .now)
        let lastReset = defaults.object(forKey: key) as? Date ?? .distantPast
        if Calendar.current.isDate(lastReset, inSameDayAs: today) == false {
            totalFocusMinutesToday = 0
            defaults.set(today, forKey: key)
            defaults.set(0, forKey: "focus.totalMinutesToday")
        }
    }
}
