import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultCanvasSize") private var defaultCanvasSize: String = CanvasSize.square.rawValue
    @AppStorage("showGridOverlay") private var showGridOverlay = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Collage Defaults
                Section("Collage Defaults") {
                    Picker("Default Canvas Size", selection: $defaultCanvasSize) {
                        ForEach(CanvasSize.allCases) { size in
                            Label(size.rawValue, systemImage: size.icon)
                                .tag(size.rawValue)
                        }
                    }

                    Toggle("Show Grid Overlay", isOn: $showGridOverlay)

                    Toggle("Auto-Save Projects", isOn: $autoSaveEnabled)
                }

                // MARK: - General
                Section("General") {
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                }

                // MARK: - Legal & Support
                Section("Legal & Support") {
                    Link(destination: URL(string: "https://chadnewbry.github.io/Snippit/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://chadnewbry.github.io/Snippit/terms-of-use")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }

                    Link(destination: URL(string: "mailto:chad.newbry@gmail.com?subject=Snippit%20Support")!) {
                        Label("Contact Support", systemImage: "envelope")
                    }
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Made with ✂️ by Chad Newbry")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
        }
        .accessibilityIdentifier("settingsTab")
    }
}

#Preview {
    SettingsView()
}
