import SwiftUI
import Combine

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var haptics: HapticsManager

    @AppStorage("landlord.settings.soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("landlord.settings.musicEnabled") private var musicEnabled: Bool = true
    @AppStorage("landlord.settings.hapticsEnabled") private var hapticsEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                soundSection
                hapticsSection
                infoSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        haptics.tap()
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }

    private var soundSection: some View {
        Section(header: Text("Sound")) {
            Toggle(isOn: $soundEnabled) {
                Text("Sound effects")
            }
            Toggle(isOn: $musicEnabled) {
                Text("Music")
            }
        }
    }

    private var hapticsSection: some View {
        Section(header: Text("Haptics")) {
            Toggle(isOn: $hapticsEnabled) {
                Text("Haptic feedback")
            }
            .onChange(of: hapticsEnabled) { _, newValue in
                if newValue {
                    haptics.soft()
                }
            }
        }
    }

    private var infoSection: some View {
        Section(header: Text("About")) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Landlord")
                    .font(.system(size: 16, weight: .semibold))
                Text("Match-style game shell with fruit theme.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
}
