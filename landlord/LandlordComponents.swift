import SwiftUI
import Combine

struct LandlordCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: () -> Content

    init(cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: LandlordTheme.Colors.tileShadow, radius: 16, x: 0, y: 10)

            content()
                .padding(16)
        }
    }
}

struct LandlordTagPill: View {
    let text: String
    var leadingIcon: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let iconName = leadingIcon {
                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .semibold))
            }
            Text(text)
                .font(LandlordTheme.Fonts.body(13))
        }
        .foregroundColor(LandlordTheme.Colors.textPrimary)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
    }
}

struct LandlordGradientButton: View {
    let title: String
    var systemIconName: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = systemIconName {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(LandlordTheme.Fonts.subtitle(15))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    colors: [
                        LandlordTheme.Colors.accent,
                        LandlordTheme.Colors.accentSecondary
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: LandlordTheme.Colors.tileShadow, radius: 10, x: 0, y: 6)
        }
    }
}

struct LandlordSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(LandlordTheme.Fonts.subtitle(15))
                .foregroundColor(LandlordTheme.Colors.textPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(LandlordTheme.Fonts.body(12))
                    .foregroundColor(LandlordTheme.Colors.textSecondary)
            }
        }
    }
}
