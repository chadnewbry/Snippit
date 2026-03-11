import Foundation

// MARK: - Edge Style

/// The style of edge applied to a clipped item's border.
enum EdgeStyle: String, CaseIterable, Identifiable, Codable {
    case roughTear = "Rough Tear"
    case scissorsCut = "Scissors Cut"
    case burntEdge = "Burnt Edge"
    case tapePatched = "Tape Patched"
    case deckled = "Deckled"
    case perforated = "Perforated"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .roughTear: return "hand.draw"
        case .scissorsCut: return "scissors"
        case .burntEdge: return "flame"
        case .tapePatched: return "bandage"
        case .deckled: return "water.waves"
        case .perforated: return "circle.dotted"
        }
    }
}

// MARK: - Craft Overlay

/// Decorative craft overlays that "attach" items to the canvas.
enum CraftOverlayType: String, CaseIterable, Identifiable, Codable {
    case washiTape = "Washi Tape"
    case pushPin = "Push Pin"
    case paperClip = "Paper Clip"
    case staple = "Staple"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .washiTape: return "bandage"
        case .pushPin: return "pin"
        case .paperClip: return "paperclip"
        case .staple: return "minus.rectangle"
        }
    }
}

// MARK: - Aging Effect

/// Aging effects that give items a vintage, worn look.
struct AgingEffect: Codable, Equatable {
    var yellowing: Double = 0       // 0...1
    var coffeeStain: Double = 0     // 0...1
    var crumpleTexture: Double = 0  // 0...1
    var fadedInk: Double = 0        // 0...1

    static let none = AgingEffect()

    var hasEffects: Bool {
        yellowing > 0 || coffeeStain > 0 || crumpleTexture > 0 || fadedInk > 0
    }
}

// MARK: - Paper Curl

/// Controls the paper curl effect at corners.
struct PaperCurlEffect: Codable, Equatable {
    var enabled: Bool = false
    var cornerIntensity: [Double] = [0, 0, 0, 0] // TL, TR, BL, BR (0...1)

    static let none = PaperCurlEffect()
}
