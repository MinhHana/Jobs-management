import SwiftUI

extension Color {
    init(hex: String) {
        let sanitized = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let length = sanitized.count
        let red, green, blue, alpha: Double

        switch length {
        case 6:
            red = Double((rgb >> 16) & 0xFF) / 255
            green = Double((rgb >> 8) & 0xFF) / 255
            blue = Double(rgb & 0xFF) / 255
            alpha = 1
        case 8:
            red = Double((rgb >> 24) & 0xFF) / 255
            green = Double((rgb >> 16) & 0xFF) / 255
            blue = Double((rgb >> 8) & 0xFF) / 255
            alpha = Double(rgb & 0xFF) / 255
        default:
            red = 0.5
            green = 0.5
            blue = 0.5
            alpha = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
