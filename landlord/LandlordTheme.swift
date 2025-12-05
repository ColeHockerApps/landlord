import SwiftUI
import Combine

struct LandlordTheme {
    struct Colors {
        static let backgroundTop = Color(red: 0.12, green: 0.14, blue: 0.22)
        static let backgroundBottom = Color(red: 0.18, green: 0.20, blue: 0.30)
        static let accent = Color(red: 0.98, green: 0.35, blue: 0.40)
        static let accentSecondary = Color(red: 0.95, green: 0.55, blue: 0.20)
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.75)
        static let tileShadow = Color.black.opacity(0.25)
    }

    struct Fonts {
        static func title(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func subtitle(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
    }
}
