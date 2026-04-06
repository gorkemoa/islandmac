import Foundation
import AppKit
import Combine

enum FocusState: String {
    case idle      = "Odaklanmaya Başla"
    case work      = "Derin Çalışma"
    case breakTime = "Mola"
}

class FocusService: ObservableObject {
    @Published var currentState: FocusState = .idle
    @Published var remainingSeconds: Int = 1500   // Varsayılan 25dk
    @Published var totalFocusMinutesToday: Int = 0
    @Published var sessionProgress: Double = 0.0  // 0.0 → 1.0 (yüzde dolması için)

    private var sessionTotalSeconds: Int = 1500
    private var timer: Timer?

    // MARK: - Oturum Yönetimi

    func startFocus(minutes: Int) {
        stopTimer()
        sessionTotalSeconds  = minutes * 60
        remainingSeconds     = sessionTotalSeconds
        sessionProgress      = 0.0
        currentState         = .work
        startTimer()
    }

    func startBreak(minutes: Int) {
        stopTimer()
        sessionTotalSeconds  = minutes * 60
        remainingSeconds     = sessionTotalSeconds
        sessionProgress      = 0.0
        currentState         = .breakTime
        startTimer()
    }

    func stop() {
        if currentState == .work {
            let elapsed = sessionTotalSeconds - remainingSeconds
            totalFocusMinutesToday += elapsed / 60
        }
        stopTimer()
        remainingSeconds = 0
        sessionProgress  = 0.0
        currentState     = .idle
    }

    // MARK: - Zamanlayıcı

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                let elapsed = Double(self.sessionTotalSeconds - self.remainingSeconds)
                self.sessionProgress = elapsed / Double(self.sessionTotalSeconds)
            } else {
                self.completeSession()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func completeSession() {
        stopTimer()
        if currentState == .work {
            totalFocusMinutesToday += sessionTotalSeconds / 60
            // macOS bildirimi gönder
            sendCompletionNotification()
        }
        currentState    = .idle
        sessionProgress = 1.0
    }

    private func sendCompletionNotification() {
        let notification = NSUserNotification()
        notification.title           = "Odak Oturumu Tamamlandı 🎯"
        notification.informativeText = "Harika iş! \(sessionTotalSeconds / 60) dakika odaklandın. Mola zamanı."
        notification.soundName       = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }

    // MARK: - Yardımcılar

    func formatTime() -> String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

