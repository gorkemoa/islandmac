import SwiftUI

struct SettingsView: View {
    @Bindable var islandState: IslandState
    
    var body: some View {
        NavigationStack {
            List {
                Section("Görünüm") {
                    Picker("Ada Modu", selection: $islandState.mode) {
                        Text("Pasif").tag(IslandMode.passive)
                        Text("Aktif").tag(IslandMode.active)
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Genişletilmiş Görünüm", isOn: $islandState.isExpanded)
                }
                
                Section("Widget Ayarları") {
                    ForEach(WidgetType.allCases, id: \.self) { widget in
                        HStack {
                            Text(widget.rawValue)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section("iPhone Bağlantısı") {
                    HStack {
                        Image(systemName: "iphone")
                        Text("Bağlı Değil")
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Bağlan") {
                            // iPhone pairing logic
                        }
                    }
                }
            }
            .navigationTitle("IslandMac Ayarlar")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        // Open help
                    }) {
                        Label("Yardım", systemImage: "questionmark.circle")
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    SettingsView(islandState: IslandState())
}
