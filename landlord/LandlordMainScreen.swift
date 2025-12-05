import SwiftUI
import Combine

struct LandlordMainScreen: View {
    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var paths: RealmPaths

    @State private var showLoading: Bool = true
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            LandlordBoardContainer()

            VStack {
                HStack {
                    Spacer(minLength: 12)

//                    Button {
//                        haptics.tap()
//                        showSettings = false
//                    } label: {
//                        Image(systemName: "gearshape.fill")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(10)
//                            .background(
//                                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                    .fill(Color.black.opacity(0.35))
//                            )
//                    }
                    .padding(.top, 18)
                    .padding(.trailing, 18)
                }

                Spacer()
            }
            .opacity(showLoading ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.25), value: showLoading)

            if showLoading {
                LoadingScreen {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showLoading = false
                    }
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen()
                .environmentObject(haptics)
        }
    }
}
