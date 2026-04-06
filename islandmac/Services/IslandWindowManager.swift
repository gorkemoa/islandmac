import SwiftUI
import AppKit
import Combine

class IslandWindowManager: NSObject, ObservableObject {
    private var window: NSPanel?
    private var islandState: IslandState
    private var screenObserver: Any?

    init(islandState: IslandState) {
        self.islandState = islandState
        super.init()
        setupWindow()
        observeScreenChanges()
    }

    // MARK: - Pencere Kurulumu

    private func setupWindow() {
        // NSPanel — aktivasyon gerektirmeyen, tüm space'lerde görünen yüzen panel
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 260),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel             = true
        panel.level                       = .statusBar  // Menü çubuğuyla aynı seviye
        panel.collectionBehavior          = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.backgroundColor             = .clear
        panel.hasShadow                   = false
        panel.isMovable                   = false
        panel.titleVisibility             = .hidden
        panel.titlebarAppearsTransparent  = true
        panel.isOpaque                    = false
        panel.ignoresMouseEvents          = false       // Tıklama olaylarını alır

        let contentView = NSHostingView(rootView: IslandView(islandState: islandState))
        contentView.layer?.backgroundColor = .clear
        panel.contentView = contentView

        self.window = panel
        updatePosition()
        panel.orderFront(nil)
    }

    // MARK: - Pozisyon Hesaplama

    func updatePosition() {
        guard let panel = window, let screen = targetScreen() else { return }

        let screenFrame = screen.frame
        let panelWidth  = panel.frame.width
        let notchHeight = notchSafeInset(screen: screen)

        // Yatay: ekran merkezine hizala
        let xPos: CGFloat = screenFrame.minX + (screenFrame.width - panelWidth) / 2

        // Dikey: notch varsa notch'un altına, yoksa ekranın tepesinden ufak padding ile
        let yPos: CGFloat = screenFrame.maxY - notchHeight - panel.frame.height

        panel.setFrameOrigin(NSPoint(x: xPos, y: yPos))
    }

    // MARK: - Çoklu Ekran Desteği

    private func targetScreen() -> NSScreen? {
        // Fare hangi ekrandaysa oraya yerleştir (çoklu monitör)
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first {
            NSMouseInRect(mouseLocation, $0.frame, false)
        } ?? NSScreen.main
    }

    // MARK: - Notch Güvenli Alan

    private func notchSafeInset(screen: NSScreen) -> CGFloat {
        if #available(macOS 12.0, *) {
            let inset = screen.safeAreaInsets.top
            // Notch var: menü çubuğu yüksekliğini de ekleyelim
            return inset > 0 ? inset : NSStatusBar.system.thickness + 2
        }
        return NSStatusBar.system.thickness + 2
    }

    // MARK: - Ekran Değişiklik Gözlemleme

    private func observeScreenChanges() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePosition()
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }
}

