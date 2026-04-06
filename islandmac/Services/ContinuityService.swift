import Foundation
import AppKit

enum ClipboardContentKind: String {
    case link
    case email
    case code
    case text
}

struct ClipboardEntry: Identifiable, Equatable {
    let id: UUID
    let content: String
    let capturedAt: Date
    let kind: ClipboardContentKind

    init(id: UUID = UUID(), content: String, capturedAt: Date = .now, kind: ClipboardContentKind) {
        self.id = id
        self.content = content
        self.capturedAt = capturedAt
        self.kind = kind
    }
}

@MainActor
final class ContinuityService: ObservableObject {
    @Published private(set) var latestEntry: ClipboardEntry?
    @Published private(set) var recentEntries: [ClipboardEntry] = []

    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int
    private var lastCapturedContent: String = ""

    init() {
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    deinit {
        timer?.invalidate()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollPasteboard()
            }
        }
        timer?.tolerance = 0.2
    }

    private func pollPasteboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        let content = pasteboard.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard content.isEmpty == false, content != lastCapturedContent else { return }
        lastCapturedContent = content

        let entry = ClipboardEntry(content: content, kind: classify(content: content))
        latestEntry = entry
        recentEntries.insert(entry, at: 0)
        recentEntries = Array(recentEntries.prefix(8))
    }

    private func classify(content: String) -> ClipboardContentKind {
        if URL(string: content)?.scheme?.hasPrefix("http") == true {
            return .link
        }
        if content.contains("@"), content.contains(".") {
            return .email
        }
        if content.contains("{") || content.contains("func ") || content.contains("let ") {
            return .code
        }
        return .text
    }
}
