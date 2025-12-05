import SwiftUI
import Combine

struct LandlordBoardContainer: View {
    @EnvironmentObject private var paths: RealmPaths
    @StateObject private var vm = LandlordBoardViewModel()

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

            ZStack {
                Color.black
                    .ignoresSafeArea()

                LandlordBoardStageView(
                    startPath: paths.restoreStoredTrail() ?? paths.entryPoint,
                    paths: paths
                ) {
                    vm.markReady()
                }
                .opacity(vm.fadeIn ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.3), value: vm.fadeIn)

                if vm.isReady == false {
                    loadingOverlay
                }
            }

            Color.black
                .opacity(vm.dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: vm.dimLayer)
        }
        .onAppear {
            vm.onAppear()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.3)

                Text("Loading board…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(LandlordTheme.Colors.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
                    .shadow(color: LandlordTheme.Colors.tileShadow, radius: 10, x: 0, y: 6)
            )
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.25), value: vm.isReady)
    }
}

final class LandlordBoardViewModel: ObservableObject {
    @Published var isReady: Bool = false
    @Published var fadeIn: Bool = false
    @Published var dimLayer: Double = 1.0

    func onAppear() {
        isReady = false
        fadeIn = false
        dimLayer = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            self.dimLayer = 0.0
        }
    }

    func markReady() {
        guard isReady == false else { return }
        isReady = true
        fadeIn = true
    }
}
