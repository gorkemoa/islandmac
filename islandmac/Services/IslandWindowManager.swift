import SwiftUI
import AppKit
import Combine

class IslandWindowManager: NSObject, ObservableObject {
    private var window: NSPanel?
    private var islandState: IslandState
    
    init(islandState: IslandState) {
        self.islandState = islandState
        super.init()
        setupWindow()
    }
    
    private func setupWindow() {
        // NSPanel ayarları: Arkada pencere açılmadan üstte yüzen bir alan
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 450),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        panel.isFloatingPanel = true
        panel.level = .mainMenu // Menü çubuğunun hemen altında/üstünde
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovable = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        
        let contentView = NSHostingView(rootView: IslandView(islandState: islandState))
        panel.contentView = contentView
        
        self.window = panel
        updatePosition()
        panel.orderFront(nil)
    }
    
    func updatePosition() {
        guard let window = window, let screen = NSScreen.main else { return }
        
        let screenFrame = screen.frame
        let windowSize = window.frame.size
        
        // Ekranın üst ortasına yerleştir
        let xPos = (screenFrame.width - windowSize.width) / 2
        let yPos = screenFrame.height - windowSize.height // Tam tepede
        
        window.setFrameOrigin(NSPoint(x: xPos, y: yPos))
    }
    
    // Notch kontrolü (isteğe bağlı Apple Silicon Mac'ler için)
    private var hasNotch: Bool {
        if #available(macOS 12.0, *) {
            return NSScreen.main?.safeAreaInsets.top ?? 0 > 0
        }
        return false
    }
}
