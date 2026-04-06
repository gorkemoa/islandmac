import SwiftUI
import AppKit
import Combine

@MainActor
final class IslandWindowManager: NSObject, ObservableObject {
    private var panel: NSPanel?
    private let appModel: AppModel
    private var cancellables = Set<AnyCancellable>()
    private var screenObserver: Any?

    init(appModel: AppModel) {
        self.appModel = appModel
        super.init()
        configurePanel()
        bindState()
        observeScreenChanges()
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }

    private func configurePanel() {
        let size = appModel.islandState.panelSize
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovable = false
        panel.isOpaque = false
        panel.hidesOnDeactivate = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        panel.contentView = NSHostingView(rootView: IslandView(appModel: appModel))
        self.panel = panel
        updatePanelFrame(animated: false)
        panel.orderFrontRegardless()
    }

    private func bindState() {
        appModel.islandState.$presentationMode
            .sink { [weak self] _ in
                self?.updatePanelFrame(animated: true)
            }
            .store(in: &cancellables)
    }

    func updatePanelFrame(animated: Bool) {
        guard let panel, let screen = targetScreen() else { return }

        let size = appModel.islandState.panelSize
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - (size.width / 2)
        let y = screen.frame.maxY - notchInset(for: screen) - size.height - 6
        let frame = NSRect(x: x, y: y, width: size.width, height: size.height)

        if animated {
            panel.animator().setFrame(frame, display: true)
        } else {
            panel.setFrame(frame, display: true)
        }
    }

    private func targetScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main
    }

    private func notchInset(for screen: NSScreen) -> CGFloat {
        if #available(macOS 12.0, *) {
            let safeInset = screen.safeAreaInsets.top
            if safeInset > 0 {
                return safeInset
            }
        }
        return NSStatusBar.system.thickness
    }

    private func observeScreenChanges() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePanelFrame(animated: false)
        }
    }
}
