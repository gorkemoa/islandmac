import SwiftUI
import EventKit

struct SettingsView: View {
    @Bindable var islandState: IslandState
    @StateObject private var calendarService = CalendarService()

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Görünüm Ayarları
                Section {
                    HStack {
                        Label("Ada Modu", systemImage: "square.topthird.inset.filled")
                        Spacer()
                        Picker("", selection: $islandState.mode) {
                            Text("Pasif").tag(IslandMode.passive)
                            Text("Mini").tag(IslandMode.mini)
                            Text("Aktif").tag(IslandMode.active)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                } header: {
                    Text("GÖRÜNÜM")
                }

                // MARK: - Widget Görünürlüğü
                Section {
                    ForEach(IslandTab.allCases) { tab in
                        let isVisible = islandState.visibleTabs.contains(tab)
                        HStack {
                            Image(systemName: tab.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 20)
                            Text(tab.rawValue)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { islandState.visibleTabs.contains(tab) },
                                set: { enabled in
                                    if enabled {
                                        if !islandState.visibleTabs.contains(tab) {
                                            islandState.visibleTabs.append(tab)
                                        }
                                    } else {
                                        islandState.visibleTabs.removeAll { $0 == tab }
                                        // En az 1 sekme kalmalı
                                        if islandState.visibleTabs.isEmpty {
                                            islandState.visibleTabs = [.media]
                                        }
                                    }
                                }
                            ))
                            .labelsHidden()
                        }
                        .opacity(isVisible ? 1 : 0.5)
                    }
                } header: {
                    Text("AKTİF SEKMELer")
                }

                // MARK: - Takvim İzni
                Section {
                    HStack {
                        Label("Takvim Erişimi", systemImage: "calendar")
                        Spacer()
                        Button("İzin İste") {
                            calendarService.requestAccess { _ in }
                        }
                        .disabled(
                            calendarService.authorizationStatus == .authorized ||
                            (calendarService.authorizationStatus.rawValue == 3)
                        )
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    HStack {
                        Text("Durum")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authStatusText(calendarService.authorizationStatus))
                            .foregroundColor(authStatusColor(calendarService.authorizationStatus))
                            .font(.system(size: 12, weight: .semibold))
                    }
                } header: {
                    Text("TAKVİM")
                }

                // MARK: - iPhone Bağlantısı
                Section {
                    HStack {
                        Label("Companion Uygulama", systemImage: "iphone")
                        Spacer()
                        Text("Bağlı Değil")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Text("iPhone'unuza IslandMac Companion uygulamasını yükleyin ve aynı iCloud hesabında oturum açın.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } header: {
                    Text("iPHONE")
                }

                // MARK: - Klavye Kısayolu
                Section {
                    HStack {
                        Label("Genişlet / Kapat", systemImage: "keyboard")
                        Spacer()
                        Text("⌘ + Shift + Space")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("KLAVYE KISAYOLLARI")
                }

                // MARK: - Hakkında
                Section {
                    HStack {
                        Text("Versiyon")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Derleme tarihi")
                        Spacer()
                        Text("2026")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("HAKKINDA")
                }
            }
            .navigationTitle("IslandMac Ayarları")
            .listStyle(.inset(alternatesRowBackgrounds: false))
        }
        .frame(minWidth: 420, minHeight: 520)
    }

    private func authStatusText(_ status: EKAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:  return "Belirlenmemiş"
        case .authorized:     return "İzin Verildi"
        case .denied:         return "Reddedildi"
        case .restricted:     return "Kısıtlı"
        default:
            if status.rawValue == 3 { return "Tam Erişim" }
            return "Bilinmiyor"
        }
    }

    private func authStatusColor(_ status: EKAuthorizationStatus) -> Color {
        switch status {
        case .authorized:    return .green
        case .denied:        return .red
        case .restricted:    return .orange
        default:
            if status.rawValue == 3 { return .green }
            return .secondary
        }
    }
}

#Preview {
    SettingsView(islandState: IslandState())
}

