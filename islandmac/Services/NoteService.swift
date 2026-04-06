import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var createdAt: Date
    var source: String

    init(id: UUID = UUID(), content: String, createdAt: Date = .now, source: String = "Mac") {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.source = source
    }
}

@MainActor
final class NoteService: ObservableObject {
    @Published private(set) var notes: [Note] = []

    private let storageURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folderURL = supportURL.appendingPathComponent("IslandMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        storageURL = folderURL.appendingPathComponent("notes.json")
        load()
    }

    func addNote(_ content: String, source: String = "Mac") {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        notes.insert(Note(content: trimmed, source: source), at: 0)
        save()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? decoder.decode([Note].self, from: data) else {
            notes = []
            return
        }
        notes = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(notes) else { return }
        try? data.write(to: storageURL, options: [.atomic])
    }
}
