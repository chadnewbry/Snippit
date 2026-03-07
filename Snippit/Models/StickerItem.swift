import Foundation
import CoreGraphics

// MARK: - Sticker Categories

enum StickerPack: String, CaseIterable, Identifiable {
    case washiTape = "Washi Tape"
    case vintageStamps = "Vintage Stamps"
    case postmarks = "Postmarks"
    case inkSplatters = "Ink Splatters"
    case flowers = "Flowers"
    case butterflies = "Butterflies"
    case stars = "Stars"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .washiTape: return "rectangle.fill"
        case .vintageStamps: return "stamp.fill"
        case .postmarks: return "envelope.fill"
        case .inkSplatters: return "drop.fill"
        case .flowers: return "camera.macro"
        case .butterflies: return "leaf.fill"
        case .stars: return "star.fill"
        }
    }

    var stickers: [StickerItem] {
        switch self {
        case .washiTape:
            return (1...6).map { i in
                StickerItem(name: "Washi \(i)", pack: self, sfSymbol: nil, style: .washiTape(patternIndex: i - 1))
            }
        case .vintageStamps:
            return (1...5).map { i in
                StickerItem(name: "Stamp \(i)", pack: self, sfSymbol: nil, style: .vintageStamp(index: i - 1))
            }
        case .postmarks:
            return (1...4).map { i in
                StickerItem(name: "Postmark \(i)", pack: self, sfSymbol: nil, style: .postmark(index: i - 1))
            }
        case .inkSplatters:
            return (1...5).map { i in
                StickerItem(name: "Splatter \(i)", pack: self, sfSymbol: nil, style: .inkSplatter(index: i - 1))
            }
        case .flowers:
            return [
                StickerItem(name: "Rose", pack: self, sfSymbol: nil, style: .flower(index: 0)),
                StickerItem(name: "Daisy", pack: self, sfSymbol: nil, style: .flower(index: 1)),
                StickerItem(name: "Sunflower", pack: self, sfSymbol: nil, style: .flower(index: 2)),
                StickerItem(name: "Lavender", pack: self, sfSymbol: nil, style: .flower(index: 3)),
                StickerItem(name: "Wildflower", pack: self, sfSymbol: nil, style: .flower(index: 4)),
            ]
        case .butterflies:
            return (1...4).map { i in
                StickerItem(name: "Butterfly \(i)", pack: self, sfSymbol: nil, style: .butterfly(index: i - 1))
            }
        case .stars:
            return [
                StickerItem(name: "Gold Star", pack: self, sfSymbol: "star.fill", style: .star(index: 0)),
                StickerItem(name: "Sparkle", pack: self, sfSymbol: "sparkle", style: .star(index: 1)),
                StickerItem(name: "Burst", pack: self, sfSymbol: "star.circle.fill", style: .star(index: 2)),
                StickerItem(name: "Shooting Star", pack: self, sfSymbol: "wand.and.stars", style: .star(index: 3)),
            ]
        }
    }
}

// MARK: - Sticker Style

enum StickerStyle: Equatable {
    case washiTape(patternIndex: Int)
    case vintageStamp(index: Int)
    case postmark(index: Int)
    case inkSplatter(index: Int)
    case flower(index: Int)
    case butterfly(index: Int)
    case star(index: Int)
}

// MARK: - Sticker Item

struct StickerItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let pack: StickerPack
    let sfSymbol: String?
    let style: StickerStyle
}
