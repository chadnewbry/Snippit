import Foundation

/// Defines which content/features are free vs premium.
enum PremiumContent {

    // MARK: - Paper Effects

    /// Edge styles available for free users.
    static let freeEdgeStyles: Set<EdgeStyle> = [.roughTear, .scissorsCut]

    /// Premium edge styles (burnt, tape-patched, deckled, perforated).
    static let premiumEdgeStyles: Set<EdgeStyle> = [.burntEdge, .tapePatched, .deckled, .perforated]

    static func isEdgeStyleFree(_ style: EdgeStyle) -> Bool {
        freeEdgeStyles.contains(style)
    }

    // MARK: - Craft Overlays

    /// Free craft overlays.
    static let freeCraftOverlays: Set<CraftOverlayType> = [.pushPin, .paperClip]

    /// Premium craft overlays.
    static let premiumCraftOverlays: Set<CraftOverlayType> = [.washiTape, .staple]

    static func isCraftOverlayFree(_ overlay: CraftOverlayType) -> Bool {
        freeCraftOverlays.contains(overlay)
    }

    // MARK: - Aging Effects

    /// Free users can use yellowing only; premium unlocks coffee stain, crumple, faded ink.
    static func isAgingParameterFree(_ keyPath: KeyPath<AgingEffect, Double>) -> Bool {
        keyPath == \.yellowing
    }

    // MARK: - Feature Checks

    static func requiresPremium(edgeStyle: EdgeStyle) -> Bool {
        premiumEdgeStyles.contains(edgeStyle)
    }

    static func requiresPremium(overlay: CraftOverlayType) -> Bool {
        premiumCraftOverlays.contains(overlay)
    }
}
