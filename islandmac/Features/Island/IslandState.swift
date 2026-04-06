import Foundation
import Combine

enum IslandPresentationMode: String, CaseIterable, Codable {
    case compact
    case expanded
}

enum IslandModule: String, CaseIterable, Identifiable, Codable {
    case overview
    case media
    case meetings
    case focus
    case tasks
    case notes
    case device

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Akış"
        case .media: return "Medya"
        case .meetings: return "Toplantı"
        case .focus: return "Odak"
        case .tasks: return "Görev"
        case .notes: return "Not"
        case .device: return "iPhone"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "sparkles.rectangle.stack"
        case .media: return "music.note.tv"
        case .meetings: return "video.badge.waveform"
        case .focus: return "timer"
        case .tasks: return "checklist"
        case .notes: return "note.text"
        case .device: return "iphone.gen3"
        }
    }
}

@MainActor
final class IslandState: ObservableObject {
    @Published var presentationMode: IslandPresentationMode
    @Published var visibleModules: [IslandModule]
    @Published var compactAccentModule: IslandModule
    @Published var hasCompletedOnboarding: Bool

    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let raw = defaults.string(forKey: "island.presentationMode"),
           let mode = IslandPresentationMode(rawValue: raw) {
            presentationMode = mode
        } else {
            presentationMode = .compact
        }

        if let modules = defaults.array(forKey: "island.visibleModules") as? [String] {
            let resolved = modules.compactMap(IslandModule.init(rawValue:))
            visibleModules = resolved.isEmpty ? IslandModule.allCases : resolved
        } else {
            visibleModules = IslandModule.allCases
        }

        if let raw = defaults.string(forKey: "island.compactAccentModule"),
           let module = IslandModule(rawValue: raw) {
            compactAccentModule = module
        } else {
            compactAccentModule = .overview
        }

        hasCompletedOnboarding = defaults.bool(forKey: "island.hasCompletedOnboarding")
        bindPersistence()
    }

    var isExpanded: Bool {
        presentationMode == .expanded
    }

    var panelSize: CGSize {
        switch presentationMode {
        case .compact:
            return CGSize(width: 430, height: 84)
        case .expanded:
            return CGSize(width: 1080, height: 540)
        }
    }

    func toggleExpanded() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            presentationMode = isExpanded ? .compact : .expanded
        }
    }

    func setExpanded(_ expanded: Bool) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            presentationMode = expanded ? .expanded : .compact
        }
    }

    func setModuleVisibility(_ module: IslandModule, isVisible: Bool) {
        if isVisible {
            if visibleModules.contains(module) == false {
                visibleModules.append(module)
            }
        } else {
            visibleModules.removeAll { $0 == module }
            if visibleModules.isEmpty {
                visibleModules = [.overview]
            }
            if compactAccentModule == module {
                compactAccentModule = visibleModules.first ?? .overview
            }
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func bindPersistence() {
        $presentationMode
            .sink { [weak self] mode in
                self?.defaults.set(mode.rawValue, forKey: "island.presentationMode")
            }
            .store(in: &cancellables)

        $visibleModules
            .sink { [weak self] modules in
                self?.defaults.set(modules.map(\.rawValue), forKey: "island.visibleModules")
            }
            .store(in: &cancellables)

        $compactAccentModule
            .sink { [weak self] module in
                self?.defaults.set(module.rawValue, forKey: "island.compactAccentModule")
            }
            .store(in: &cancellables)

        $hasCompletedOnboarding
            .sink { [weak self] value in
                self?.defaults.set(value, forKey: "island.hasCompletedOnboarding")
            }
            .store(in: &cancellables)
    }
}
