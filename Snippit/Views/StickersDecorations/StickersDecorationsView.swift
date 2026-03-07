import SwiftUI

enum DecorationTab: String, CaseIterable, Identifiable {
    case stickers = "Stickers"
    case doodle = "Doodle"
    case shapes = "Shapes"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .stickers: return "star.circle.fill"
        case .doodle: return "pencil.tip"
        case .shapes: return "seal.fill"
        }
    }
}

struct StickersDecorationsView: View {
    @State private var selectedTab: DecorationTab = .stickers
    @State private var placedStickers: [PlacedDecoration] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Canvas preview area
                DecorationCanvasView(placedDecorations: $placedStickers)
                    .frame(maxHeight: .infinity)

                Divider()

                // Tab selector
                DecorationTabBar(selectedTab: $selectedTab)

                // Content panel
                Group {
                    switch selectedTab {
                    case .stickers:
                        StickerPackBrowserView(onStickerSelected: addSticker)
                    case .doodle:
                        DoodleToolView(onStrokeComplete: addDoodle)
                    case .shapes:
                        ShapeStampPickerView(onShapeSelected: addShape)
                    }
                }
                .frame(height: 260)
            }
            .navigationTitle("Decorations")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("stickersDecorationsView")
    }

    private func addSticker(_ sticker: StickerItem) {
        let decoration = PlacedDecoration(
            kind: .sticker(sticker),
            position: CGPoint(x: 180 + CGFloat.random(in: -40...40), y: 300 + CGFloat.random(in: -40...40)),
            rotation: Double.random(in: -0.2...0.2)
        )
        placedStickers.append(decoration)
    }

    private func addDoodle(_ stroke: DoodleStroke) {
        let decoration = PlacedDecoration(
            kind: .doodle(stroke),
            position: .zero,
            rotation: 0
        )
        placedStickers.append(decoration)
    }

    private func addShape(_ shape: ShapeStamp) {
        let decoration = PlacedDecoration(
            kind: .shape(shape),
            position: CGPoint(x: 180 + CGFloat.random(in: -40...40), y: 300 + CGFloat.random(in: -40...40)),
            rotation: 0
        )
        placedStickers.append(decoration)
    }
}

// MARK: - Placed Decoration

struct PlacedDecoration: Identifiable {
    let id = UUID()
    var kind: DecorationKind
    var position: CGPoint
    var rotation: Double
    var scale: CGFloat = 1.0
}

enum DecorationKind {
    case sticker(StickerItem)
    case doodle(DoodleStroke)
    case shape(ShapeStamp)
}

#Preview {
    StickersDecorationsView()
}
