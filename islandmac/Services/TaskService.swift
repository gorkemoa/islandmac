import Foundation

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case critical
    case high
    case normal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .critical: return "Kritik"
        case .high: return "Yüksek"
        case .normal: return "Normal"
        }
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var createdAt: Date
    var dueDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var priority: TaskPriority

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = .now,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        priority: TaskPriority = .normal
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.priority = priority
    }
}

@MainActor
final class TaskService: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []

    private let storageURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init() {
        let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folderURL = supportURL.appendingPathComponent("IslandMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        storageURL = folderURL.appendingPathComponent("tasks.json")
        load()
    }

    var openTasks: [TaskItem] {
        tasks
            .filter { $0.isCompleted == false }
            .sorted(by: sortOpenTasks)
    }

    var criticalTasks: [TaskItem] {
        openTasks.filter { $0.priority == .critical || $0.priority == .high }
    }

    var completedTodayCount: Int {
        let calendar = Calendar.current
        return tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }.count
    }

    var overdueCount: Int {
        let now = Date()
        return openTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now
        }.count
    }

    func addTask(title: String, priority: TaskPriority = .normal, dueDate: Date? = nil) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let task = TaskItem(title: trimmed, dueDate: dueDate, priority: priority)
        tasks.append(task)
        save()
    }

    func toggleCompletion(for taskID: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].isCompleted.toggle()
        tasks[index].completedAt = tasks[index].isCompleted ? .now : nil
        save()
    }

    func removeTask(_ taskID: UUID) {
        tasks.removeAll { $0.id == taskID }
        save()
    }

    func updatePriority(for taskID: UUID, priority: TaskPriority) {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else { return }
        tasks[index].priority = priority
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL),
              let decoded = try? decoder.decode([TaskItem].self, from: data) else {
            tasks = []
            return
        }
        tasks = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(tasks) else { return }
        try? data.write(to: storageURL, options: [.atomic])
    }

    private func sortOpenTasks(lhs: TaskItem, rhs: TaskItem) -> Bool {
        let leftDue = lhs.dueDate ?? .distantFuture
        let rightDue = rhs.dueDate ?? .distantFuture

        if lhs.priority != rhs.priority {
            return priorityScore(lhs.priority) > priorityScore(rhs.priority)
        }

        if leftDue != rightDue {
            return leftDue < rightDue
        }

        return lhs.createdAt > rhs.createdAt
    }

    private func priorityScore(_ priority: TaskPriority) -> Int {
        switch priority {
        case .critical: return 3
        case .high: return 2
        case .normal: return 1
        }
    }
}
