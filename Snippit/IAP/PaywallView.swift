import RevenueCat
import SwiftUI

/// Full-screen paywall for upgrading to Snippit Premium.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.purple.opacity(0.15), .pink.opacity(0.10), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        featuresSection
                        pricingSection
                        restoreButton
                        legalText
                    }
                    .padding()
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
            .accessibilityIdentifier("paywallView")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "scissors")
                .font(.system(size: 48))
                .foregroundStyle(.purple)
                .symbolEffect(.bounce, options: .nonRepeating)

            Text("Snippit Premium")
                .font(.largeTitle.weight(.bold))

            Text("Unlock the full creative toolkit")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "infinity", title: "Unlimited Saves", description: "No more limits on your creativity")
            FeatureRow(icon: "books.vertical", title: "Curated Collections", description: "Access exclusive magazine collections")
            FeatureRow(icon: "flame.fill", title: "Premium Paper Effects", description: "Burnt edges, deckled, perforated & more")
            FeatureRow(icon: "star.fill", title: "Exclusive Sticker Packs", description: "Washi tape, staples & craft overlays")
            FeatureRow(icon: "paintbrush.fill", title: "Advanced Aging Effects", description: "Coffee stains, crumple textures & faded ink")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Pricing

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if let package = subscriptionManager.offerings?.current?.annual {
                Button {
                    Task { await purchase(package: package) }
                } label: {
                    VStack(spacing: 4) {
                        Text("Subscribe for \(package.localizedPriceString)/year")
                            .font(.headline)
                        Text("That's less than \(monthlyEquivalent(package: package))/month")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isPurchasing)
            } else {
                // Fallback when offerings haven't loaded
                Button {
                    Task { await subscriptionManager.loadOfferings() }
                } label: {
                    VStack(spacing: 4) {
                        Text("$19.99/year")
                            .font(.headline)
                        Text("Tap to load pricing")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            }

            if isPurchasing {
                ProgressView()
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                do {
                    try await subscriptionManager.restorePurchases()
                    if subscriptionManager.isPremium { dismiss() }
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    // MARK: - Legal

    private var legalText: some View {
        Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    // MARK: - Helpers

    private func purchase(package: Package) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await subscriptionManager.purchase(package: package)
            if subscriptionManager.isPremium { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func monthlyEquivalent(package: Package) -> String {
        guard let price = package.storeProduct.priceDecimalNumber as? NSDecimalNumber else {
            return "$1.67"
        }
        let monthly = price.doubleValue / 12.0
        return String(format: "$%.2f", monthly)
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.purple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
}
