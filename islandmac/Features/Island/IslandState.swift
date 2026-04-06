import SwiftUI

// MARK: - Ada Mod Tanımları

enum IslandMode: Equatable {
    case passive     // Notch boyutunda minimal
    case mini        // Küçük özet bilgi
    case active      // Normal aktif durum
    case expanded    // Genişletilmiş panel (tıklanınca)
    case fullPanel   // Tam panel
}

// MARK: - Sekme Tanımları

enum IslandTab: String, CaseIterable, Identifiable {
    case media    = "Medya"
    case meetings = "Toplantı"
    case focus    = "Odak"
    case tasks    = "Görevler"
    case notes    = "Notlar"
    case device   = "iPhone"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .media:    return "music.note"
        case .meetings: return "video.fill"
        case .focus:    return "timer"
        case .tasks:    return "checkmark.circle"
        case .notes:    return "note.text"
        case .device:   return "iphone"
        }
    }
}

// MARK: - IslandState

@Observable
class IslandState {
    var mode: IslandMode = .active
    var isExpanded: Bool = false
    var activeTab: IslandTab = .media

    // Hangi sekmelerin göründüğü (kullanıcı ayarlarla değiştirebilir)
    var visibleTabs: [IslandTab] = IslandTab.allCases

    // İlk açılış onboarding kontrolü
    var hasCompletedOnboarding: Bool = false

    // Eski uyumluluk — bazı view'lar hâlâ WidgetType kullanıyorsa
    var currentWidgetType: WidgetType = .calendar
}

// MARK: - Eski WidgetType (uyumluluk için tutuldu)

enum WidgetType: String, CaseIterable {
    case calendar     = "Bugün"
    case meetings     = "Toplantı"
    case focus        = "Odak"
    case tasks        = "Görevler"
    case notes        = "Notlar"
    case deviceStatus = "iPhone"
}
