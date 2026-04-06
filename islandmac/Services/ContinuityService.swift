import Foundation
import AppKit
import Combine

class ContinuityService: ObservableObject {
    @Published var lastClipboardContent: String?
    @Published var isFromiPhone: Bool = false
    
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var changeCount: Int
    
    init() {
        self.changeCount = pasteboard.changeCount
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }
    
    private func checkPasteboard() {
        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount
            if let content = pasteboard.string(forType: .string) {
                // macOS'ta Universal Clipboard ile kopyalanan şeylerin 
                // iPhone'dan gelip gelmediğini anlamak için Apple SDK'larından (Handoff) 
                // gelen verileri (isteğe bağlı) check edebiliriz. 
                // Şimdilik premium hissi için her yeni kopyalamayı 
                // 'Yeni Bağlam' olarak adada kısa süre gösterelim.
                self.lastClipboardContent = content
                self.isFromiPhone = true // Mock: Tüm yeni kopyalamaları 'iPhone Devam' gibi simüle edelim.
                
                // 10 saniye sonra adadan bu devamlılık uyarısını kaldıralım
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if self.lastClipboardContent == content {
                        self.lastClipboardContent = nil
                    }
                }
            }
        }
    }
}
