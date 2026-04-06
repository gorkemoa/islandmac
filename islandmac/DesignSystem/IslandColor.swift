import SwiftUI

enum IslandColor {
    static let panelBase = Color(hex: "080A14")
    static let panelElevated = Color(hex: "12182B")
    static let accentBlue = Color(hex: "5EA0FF")
    static let accentPink = Color(hex: "E870FF")
    static let accentOrange = Color(hex: "FF9A45")
    static let accentRed = Color(hex: "FF5F57")
    static let focusOrange = Color(hex: "FFB347")
    static let successGreen = Color(hex: "37D67A")
    static let noteYellow = Color(hex: "FFD76A")
    static let mutedText = Color.white.opacity(0.58)
    static let border = Color.white.opacity(0.08)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
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
