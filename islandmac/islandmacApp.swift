import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var islandState = IslandState()
    var windowManager: IslandWindowManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // IslandWindowManager initialization
        windowManager = IslandWindowManager(islandState: islandState)
    }
}

@main
struct islandmacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // macOS'ta varsayılan ana pencereyi (ayarlar için) tanımlıyoruz
        WindowGroup {
            SettingsView(islandState: appDelegate.islandState)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 450, height: 600)
    }
}
