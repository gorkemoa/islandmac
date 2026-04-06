import Foundation
import Combine

struct DeviceInfo: Identifiable {
    let id = UUID()
    let name: String
    var batteryLevel: Double
    var isCharging: Bool
    var lastSync: Date
}

class DeviceSyncService: ObservableObject {
    @Published var linkediPhone: DeviceInfo?
    @Published var isSyncing: Bool = false
    
    init() {
        // Başlangıçta mock veri ile premium hissi verelim (gerçek bağlantı logic'i onboarding'de kurulur)
        self.linkediPhone = DeviceInfo(
            name: "iPhone 15 Pro",
            batteryLevel: 0.85,
            isCharging: false,
            lastSync: Date()
        )
    }
    
    func startSync() {
        isSyncing = true
        // Simüle edilmiş ağ gecikmesi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSyncing = false
            self.linkediPhone?.lastSync = Date()
            self.linkediPhone?.batteryLevel = Double.random(in: 0.8...0.95)
        }
    }
}
