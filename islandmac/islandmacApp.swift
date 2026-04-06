import SwiftUI
import AppKit

// MARK: - Uygulama Delegesi

class AppDelegate: NSObject, NSApplicationDelegate {
    let islandState = IslandState()
    var windowManager: IslandWindowManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dock ikonunu gizle — menü çubuğu / üst alan uygulaması
        NSApp.setActivationPolicy(.accessory)

        // Island penceresini başlat
        windowManager = IslandWindowManager(islandState: islandState)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Ayarlar penceresi kapansa bile uygulama çalışmaya devam etsin
        return false
    }
}

// MARK: - Ana Uygulama

@main
struct islandmacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Ayarlar / ana pencere
        WindowGroup("IslandMac Ayarları") {
            SettingsView(islandState: appDelegate.islandState)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 450, height: 580)

        // macOS 13+ Settings sahnesi (⌘, kısayolu ile açılır)
        Settings {
            SettingsView(islandState: appDelegate.islandState)
        }
    }
}

