import Foundation
import Combine

enum FocusState: String {
    case idle = "Odaklanmaya Başla"
    case work = "Derin Çalışma"
    case breakTime = "Mola"
}

class FocusService: ObservableObject {
    @Published var currentState: FocusState = .idle
    @Published var remainingSeconds: Int = 1500 // Varsayılan 25dk
    @Published var totalFocusMinutesToday: Int = 0
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    func startFocus(minutes: Int) {
        stopTimer()
        remainingSeconds = minutes * 60
        currentState = .work
        startTimer()
    }
    
    func startBreak(minutes: Int) {
        stopTimer()
        remainingSeconds = minutes * 60
        currentState = .breakTime
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
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
             totalFocusMinutesToday += 25 // Örnek olarak
        }
        currentState = .idle
    }
    
    func formatTime() -> String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
