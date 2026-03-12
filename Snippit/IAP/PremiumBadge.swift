import SwiftUI

/// Small lock/crown badge overlay for premium-only content.
struct PremiumBadge: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.caption2)
            .foregroundStyle(.white)
            .padding(4)
            .background(.purple, in: Circle())
    }
}

/// Modifier that overlays a premium badge and shows paywall on tap for locked content.
struct PremiumGate: ViewModifier {
    let isLocked: Bool
    @State private var showPaywall = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if isLocked {
                    PremiumBadge()
                        .padding(4)
                }
            }
            .opacity(isLocked ? 0.6 : 1.0)
            .onTapGesture {
                if isLocked { showPaywall = true }
            }
            .allowsHitTesting(isLocked ? true : false) // only intercept taps when locked
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
    }
}

extension View {
    /// Gates content behind premium — shows lock badge and paywall on tap.
    func premiumGate(isLocked: Bool) -> some View {
        modifier(PremiumGate(isLocked: isLocked))
    }
}
