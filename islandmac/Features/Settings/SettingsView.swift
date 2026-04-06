import SwiftUI
import EventKit
import AppKit

struct SettingsView: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        NavigationStack {
            List {
                Section("Görünüm") {
                    Picker("Ada modu", selection: $appModel.islandState.presentationMode) {
                        Text("Kompakt").tag(IslandPresentationMode.compact)
                        Text("Geniş").tag(IslandPresentationMode.expanded)
                    }
                    .pickerStyle(.segmented)

                    Picker("Kompakt vurgu", selection: $appModel.islandState.compactAccentModule) {
                        ForEach(appModel.islandState.visibleModules) { module in
                            Text(module.title).tag(module)
                        }
                    }
                }

                Section("Modüller") {
                    ForEach(IslandModule.allCases) { module in
                        Toggle(isOn: Binding(
                            get: { appModel.islandState.visibleModules.contains(module) },
                            set: { appModel.islandState.setModuleVisibility(module, isVisible: $0) }
                        )) {
                            Label(module.title, systemImage: module.icon)
                        }
                    }
                }

                Section("Takvim") {
                    LabeledContent("Erişim", value: authStatusText(appModel.calendarService.authorizationStatus))
                    LabeledContent("Bugünkü yoğunluk", value: appModel.calendarService.densityText)
                    LabeledContent("Boş alan", value: appModel.calendarService.nextFreeWindowText)

                    Button("Takvim izni iste") {
                        appModel.calendarService.requestAccess { _ in }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(appModel.calendarService.hasCalendarAccess)
                }

                Section("Medya") {
                    if let media = appModel.mediaService.currentMedia {
                        LabeledContent("Kaynak", value: media.platform.rawValue)
                        LabeledContent("Parça", value: media.title)
                        LabeledContent("Durum", value: media.isPlaying ? "Çalıyor" : "Duraklatıldı")
                    } else {
                        Text("Apple Music, Spotify veya Chrome sekmesinde bir şey çaldığında ada otomatik olarak medya kartına geçer.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Companion") {
                    LabeledContent("Durum", value: appModel.deviceService.connectionState.rawValue)
                    LabeledContent("Eşleştirme kodu", value: appModel.deviceService.pairingCode)
                    Text("Companion uygulama veya dış istemci \(appModel.deviceService.inboxURL.path) dosyasına güncel JSON yazarsa ada anında bağlanır.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Inbox klasörünü aç") {
                        NSWorkspace.shared.activateFileViewerSelecting([appModel.deviceService.inboxURL.deletingLastPathComponent()])
                    }
                }

                Section("Odak ve notlar") {
                    LabeledContent("Bugünkü odak", value: "\(appModel.focusService.totalFocusMinutesToday) dk")
                    LabeledContent("Açık görev", value: "\(appModel.taskService.openTasks.count)")
                    LabeledContent("Not sayısı", value: "\(appModel.noteService.notes.count)")
                }

                Section("Sıfırla") {
                    Button("Onboarding'i tekrar göster") {
                        appModel.islandState.hasCompletedOnboarding = false
                    }
                }
            }
            .navigationTitle("IslandMac")
            .listStyle(.insetGrouped)
        }
        .frame(minWidth: 560, minHeight: 640)
    }

    private func authStatusText(_ status: EKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Bekleniyor"
        case .restricted:
            return "Kısıtlı"
        case .denied:
            return "Reddedildi"
        case .authorized:
            return "Verildi"
        @unknown default:
            if status.rawValue == 3 {
                return "Tam erişim"
            }
            return "Bilinmiyor"
        }
    }
}
