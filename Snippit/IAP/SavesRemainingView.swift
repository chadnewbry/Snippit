import SwiftUI

/// Shows remaining free saves with an upgrade prompt when running low.
struct SavesRemainingView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        if subscriptionManager.isPremium {
            // Premium users see nothing — unlimited saves
            EmptyView()
        } else {
            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: savesIcon)
                        .foregroundStyle(savesColor)

                    Text("\(subscriptionManager.savesRemaining) saves left")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(savesColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(savesColor.opacity(0.12), in: Capsule())
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .accessibilityIdentifier("savesRemaining")
        }
    }

    private var savesIcon: String {
        switch subscriptionManager.savesRemaining {
        case 0: return "exclamationmark.triangle.fill"
        case 1...2: return "exclamationmark.circle.fill"
        default: return "square.and.arrow.down"
        }
    }

    private var savesColor: Color {
        switch subscriptionManager.savesRemaining {
        case 0: return .red
        case 1...2: return .orange
        default: return .purple
        }
    }
}

/// Modifier that shows paywall when user tries to save without remaining saves.
struct PremiumSaveGuard: ViewModifier {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    let onAllowed: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                if subscriptionManager.canSave {
                    subscriptionManager.recordSave()
                    onAllowed()
                } else {
                    showPaywall = true
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
    }
}

extension View {
    /// Wraps a save action — shows paywall if free limit reached.
    func premiumSaveGuard(onAllowed: @escaping () -> Void) -> some View {
        modifier(PremiumSaveGuard(onAllowed: onAllowed))
    }
}

#Preview {
    SavesRemainingView()
}
