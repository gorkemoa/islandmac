import Foundation
import Combine
import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var createdAt: Date
    var isFromiPhone: Bool
}

class NoteService: ObservableObject {
    @Published var notes: [Note] = []
    
    init() {
        // Mock başlangıç notu (Continuity hissi için)
        self.notes = [
            Note(id: UUID(), content: "Müşteri sunum notları", createdAt: Date(), isFromiPhone: true)
        ]
    }
    
    func addNote(_ content: String, fromiPhone: Bool = false) {
        let newNote = Note(id: UUID(), content: content, createdAt: Date(), isFromiPhone: fromiPhone)
        notes.insert(newNote, at: 0)
        // Persistence logic can be added here (SwiftData)
    }
    
    func deleteNote(at indexSet: IndexSet) {
        notes.remove(atOffsets: indexSet)
    }
}
