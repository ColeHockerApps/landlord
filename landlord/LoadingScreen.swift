import SwiftUI
import Combine

struct LoadingScreen: View {
    var onFinished: (() -> Void)?

    private let duration: TimeInterval = 3.0

    @State private var progress: CGFloat = 0.0
    @State private var animationStarted = false

    @State private var boardPoppedIn = false
    @State private var appleDropped = false
    @State private var mushroomDropped = false
    @State private var carrotDropped = false
    @State private var strawberryDropped = false

    @State private var fadeOut = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LandlordTheme.Colors.backgroundTop,
                    LandlordTheme.Colors.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 80)   // ⬆️ подняли титульник

                VStack(spacing: 8) {
                    Text("Road-Farmer")
                        .font(LandlordTheme.Fonts.title(34))
                        .foregroundColor(LandlordTheme.Colors.textPrimary)

                    Text("Match the fruits. Own the farm.")
                        .font(LandlordTheme.Fonts.subtitle(16))
                        .foregroundColor(LandlordTheme.Colors.textSecondary)
                }
                .padding(.bottom, 30) // ⬆️ больше воздуха под текстом

                boardView
                    .padding(.top, 8)

                Spacer()

                progressSection

                Spacer().frame(height: 32)
            }
            .padding(.horizontal, 24)
            .opacity(fadeOut ? 0.0 : 1.0)
            .scaleEffect(fadeOut ? 0.97 : 1.0)
        }
        .onAppear {
            startAnimationIfNeeded()
        }
    }

    private var boardView: some View {
        ZStack {
            VStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 8) {
                        ForEach(0..<3) { _ in
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 64, height: 64)
                                .shadow(color: LandlordTheme.Colors.tileShadow, radius: 6, x: 0, y: 4)
                        }
                    }
                }
            }

            fruitLayer
        }
        .scaleEffect(boardPoppedIn ? 1.0 : 0.8)
        .opacity(boardPoppedIn ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1),
            value: boardPoppedIn
        )
    }

    private var fruitLayer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Spacer().frame(width: 64)
                fruitImage(name: LandlordAssets.Images.apple, isDropped: appleDropped)
                Spacer().frame(width: 64)
            }
            HStack(spacing: 8) {
                fruitImage(name: LandlordAssets.Images.mushroom, isDropped: mushroomDropped)
                Spacer().frame(width: 64)
                fruitImage(name: LandlordAssets.Images.carrot, isDropped: carrotDropped)
            }
            HStack(spacing: 8) {
                Spacer().frame(width: 64)
                fruitImage(name: LandlordAssets.Images.strawberry, isDropped: strawberryDropped)
                Spacer().frame(width: 64)
            }
        }
    }

    private func fruitImage(name: String, isDropped: Bool) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 56, height: 56)
            .shadow(radius: 8)
            .offset(y: isDropped ? 0 : -140)
            .scaleEffect(isDropped ? 1.0 : 0.9)
            .animation(
                .interpolatingSpring(stiffness: 180, damping: 16),
                value: isDropped
            )
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 10)

                    Capsule()
                        .fill(LandlordTheme.Colors.accent)
                        .frame(width: proxy.size.width * progress, height: 10)
                        .shadow(color: LandlordTheme.Colors.tileShadow, radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 16)

            Text("Loading game…")
                .font(LandlordTheme.Fonts.body(14))
                .foregroundColor(LandlordTheme.Colors.textSecondary)
        }
    }

    private func startAnimationIfNeeded() {
        guard !animationStarted else { return }
        animationStarted = true

        // board pop
        withAnimation {
            boardPoppedIn = true
        }

        // sequential fruit drops
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appleDropped = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            mushroomDropped = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            carrotDropped = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            strawberryDropped = true
        }

        // progress bar
        withAnimation(.linear(duration: duration)) {
            progress = 1.0
        }

        // fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + (duration - 0.25)) {
            withAnimation(.easeInOut(duration: 0.25)) {
                fadeOut = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            onFinished?()
        }
    }
}
