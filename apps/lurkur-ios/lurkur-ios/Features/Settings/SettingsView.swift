import SwiftUI

struct SettingsView: View {
    @Environment(AuthService.self) private var auth
    @Environment(PreferencesStore.self) private var preferences
    @State private var confirmClear = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Brightness", selection: brightnessBinding) {
                    ForEach(ThemeBrightness.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
            }

            Section("Comments") {
                Toggle("Hide AutoModerator comments", isOn: hideAutoModBinding)
            }

            Section("Hidden subreddits") {
                if preferences.hiddenSubreddits.isEmpty {
                    Text("None")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(preferences.hiddenSubreddits.sorted(), id: \.self) { name in
                        HStack {
                            Text("r/\(name)")
                            Spacer()
                            Button("Unhide") {
                                preferences.showSubreddit(name)
                            }
                        }
                    }
                }
            }

            Section("Session") {
                Button("Clear all settings", role: .destructive) {
                    confirmClear = true
                }
                Button("Log out", role: .destructive) {
                    Task { await auth.logout() }
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Clear all settings?",
            isPresented: $confirmClear,
            titleVisibility: .visible
        ) {
            Button("Clear all settings", role: .destructive) {
                preferences.clearAll()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var brightnessBinding: Binding<ThemeBrightness> {
        Binding(
            get: { preferences.brightness },
            set: { preferences.setBrightness($0) }
        )
    }

    private var hideAutoModBinding: Binding<Bool> {
        Binding(
            get: { preferences.hideAutoModeratorComments },
            set: { preferences.setHideAutoModeratorComments($0) }
        )
    }
}
