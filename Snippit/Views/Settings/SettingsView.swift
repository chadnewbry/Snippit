import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultCanvasSize") private var defaultCanvasSize: String = CanvasSize.square.rawValue
    @AppStorage("showGridOverlay") private var showGridOverlay = true
    @AppStorage("autoSaveEnabled") private var autoSaveEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Premium
                Section {
                    if subscriptionManager.isPremium {
                        Label("Snippit Premium", systemImage: "crown.fill")
                            .foregroundStyle(.purple)
                        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                            Label("Manage Subscription", systemImage: "creditcard")
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Label("Upgrade to Premium", systemImage: "crown")
                                Spacer()
                                Text("\(subscriptionManager.savesRemaining) saves left")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Button("Restore Purchases") {
                            Task { try? await subscriptionManager.restorePurchases() }
                        }
                        .font(.subheadline)
                    }
                } header: {
                    Text("Subscription")
                }

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
                    Link(destination: URL(string: AppConfig.shared.urls.privacyPolicy)!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: AppConfig.shared.urls.termsOfService)!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }

                    Button {
                        let email = AppConfig.shared.review?.contactEmail ?? "chad.newbry@gmail.com"
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .accessibilityIdentifier("settingsTab")
    }
}

#Preview {
    SettingsView()
}
