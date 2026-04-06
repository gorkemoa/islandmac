import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let appModel = AppModel()
    var windowManager: IslandWindowManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        windowManager = IslandWindowManager(appModel: appModel)

        if appModel.islandState.hasCompletedOnboarding == false {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@main
struct islandmacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("IslandMac") {
            if appDelegate.appModel.islandState.hasCompletedOnboarding {
                SettingsView(appModel: appDelegate.appModel)
            } else {
                OnboardingView(appModel: appDelegate.appModel)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 700, height: 720)

        Settings {
            SettingsView(appModel: appDelegate.appModel)
        }
    }
}
