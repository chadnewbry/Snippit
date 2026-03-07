import SwiftUI

struct DecorationItemView: View {
    let decoration: PlacedDecoration

    var body: some View {
        switch decoration.kind {
        case .sticker(let sticker):
            StickerRendererView(sticker: sticker)
        case .doodle(let stroke):
            DoodleStrokeRendererView(stroke: stroke)
        case .shape(let shape):
            ShapeStampRendererView(shape: shape)
        }
    }
}
