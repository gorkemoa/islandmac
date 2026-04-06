import SwiftUI

enum IslandColor {
    static let primaryBackground = Color(hex: "060606") // Ultra deep black
    static let accentBlue = Color(hex: "0A84FF") // Premium iOS Blue
    static let focusOrange = Color(hex: "FF9F0A") // Premium Focus Orange
    static let successGreen = Color(hex: "30D158") // Green for battery & sync
    static let noteYellow = Color(hex: "FFD60A") // Note Yellow
    static let glassOverlay = Color.white.opacity(0.04)
    static let glassBorder = Color.white.opacity(0.12)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
