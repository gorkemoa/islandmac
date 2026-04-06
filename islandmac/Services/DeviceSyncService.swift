import Foundation

enum DeviceConnectionState: String {
    case waiting = "Eşleştirme bekleniyor"
    case connected = "Bağlı"
    case stale = "Bağlantı koptu"
}

struct DeviceSnapshot: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var batteryLevel: Double?
    var isCharging: Bool
    var focusMode: String?
    var lastSync: Date
    var lastSharedNote: String?

    init(
        id: UUID = UUID(),
        name: String,
        batteryLevel: Double? = nil,
        isCharging: Bool = false,
        focusMode: String? = nil,
        lastSync: Date = .now,
        lastSharedNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
        self.focusMode = focusMode
        self.lastSync = lastSync
        self.lastSharedNote = lastSharedNote
    }
}

@MainActor
final class DeviceSyncService: ObservableObject {
    @Published private(set) var linkedDevice: DeviceSnapshot?
    @Published private(set) var connectionState: DeviceConnectionState = .waiting
    @Published private(set) var pairingCode: String
    @Published private(set) var inboxURL: URL

    private var pollTimer: Timer?
    private let decoder = JSONDecoder()

    init() {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folderURL = supportURL.appendingPathComponent("IslandMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        inboxURL = folderURL.appendingPathComponent("companion.json")
        pairingCode = String(UUID().uuidString.prefix(6)).uppercased()

        refreshFromInbox()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshFromInbox()
            }
        }
        pollTimer?.tolerance = 1
    }

    deinit {
        pollTimer?.invalidate()
    }

    func refreshFromInbox() {
        guard let data = try? Data(contentsOf: inboxURL),
              let snapshot = try? decoder.decode(DeviceSnapshot.self, from: data) else {
            linkedDevice = nil
            connectionState = .waiting
            return
        }

        linkedDevice = snapshot
        let age = Date().timeIntervalSince(snapshot.lastSync)
        connectionState = age <= 180 ? .connected : .stale
    }

    var lastSyncText: String {
        guard let linkedDevice else { return "Henüz veri yok" }
        let diff = Int(Date().timeIntervalSince(linkedDevice.lastSync))
        if diff < 60 { return "Az önce" }
        if diff < 3600 { return "\(diff / 60) dk önce" }
        return "\(diff / 3600) sa önce"
    }
}
