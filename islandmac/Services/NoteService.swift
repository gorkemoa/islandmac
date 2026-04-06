import Foundation
import SwiftUI
import Combine

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var createdAt: Date
    var isFromiPhone: Bool

    init(id: UUID = UUID(), content: String, createdAt: Date = Date(), isFromiPhone: Bool = false) {
        self.id           = id
        self.content      = content
        self.createdAt    = createdAt
        self.isFromiPhone = isFromiPhone
    }
}

class NoteService: ObservableObject {
    @Published var notes: [Note] = []

    private let storageKey = "islandmac.notes"

    init() {
        loadNotes()
        // Hiç not yoksa örnek birini ekle
        if notes.isEmpty {
            notes = [
                Note(content: "Müşteri sunum notları", isFromiPhone: true)
            ]
        }
    }

    // MARK: - CRUD

    func addNote(_ content: String, fromiPhone: Bool = false) {
        let note = Note(content: content, isFromiPhone: fromiPhone)
        notes.insert(note, at: 0)
        saveNotes()
    }

    func deleteNote(at indexSet: IndexSet) {
        notes.remove(atOffsets: indexSet)
        saveNotes()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }

    // MARK: - Persistence (UserDefaults — hafif veriler için yeterli)

    private func saveNotes() {
        guard let encoded = try? JSONEncoder().encode(notes) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    private func loadNotes() {
        guard
            let data    = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Note].self, from: data)
        else { return }
        notes = decoded
    }
}

