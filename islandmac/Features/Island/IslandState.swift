import SwiftUI

enum IslandMode: Equatable {
    case passive          // Kapalı, çok küçük (notch hizasında)
    case mini             // Sadece kritik bir simge/sayı
    case active          // Aktif bilgi (toplantı sayacı, odak süresi)
    case expanded        // Genişletilmiş detaylı görünüm (tıklandığında)
    case fullPanel       // Tam detay paneli (daha geniş bilgi)
}

@Observable
class IslandState {
    var mode: IslandMode = .active
    var isExpanded: Bool = false
    var currentWidgetType: WidgetType = .calendar
    
    // Uygulamanın üst orta konumda kalmasını sağlayan manager ile haberleşecek
    var xPosition: CGFloat = 0.5 // Merkeze oranlı
    var yPosition: CGFloat = 0.0 // En üst
}

enum WidgetType: String, CaseIterable {
    case calendar = "Bugün"
    case meetings = "Toplantı"
    case focus = "Odak"
    case tasks = "Görevler"
    case notes = "Notlar"
    case deviceStatus = "iPhone"
}
