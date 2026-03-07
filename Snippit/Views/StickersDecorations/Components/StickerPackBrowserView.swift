import SwiftUI

struct StickerPackBrowserView: View {
    let onStickerSelected: (StickerItem) -> Void
    @State private var selectedPack: StickerPack = .washiTape

    var body: some View {
        VStack(spacing: 0) {
            // Pack selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(StickerPack.allCases) { pack in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPack = pack
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: pack.icon)
                                    .font(.title3)
                                Text(pack.rawValue)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedPack == pack
                                        ? Color(red: 0.82, green: 0.55, blue: 0.60).opacity(0.3)
                                        : Color(.tertiarySystemGroupedBackground))
                            )
                            .foregroundStyle(selectedPack == pack
                                ? Color(red: 0.65, green: 0.16, blue: 0.16)
                                : .secondary)
                        }
                        .accessibilityIdentifier("stickerPack_\(pack.rawValue)")
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 8)

            Divider()

            // Sticker grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 72, maximum: 90), spacing: 12)
                ], spacing: 12) {
                    ForEach(selectedPack.stickers) { sticker in
                        Button {
                            onStickerSelected(sticker)
                        } label: {
                            StickerRendererView(sticker: sticker)
                                .frame(width: 72, height: 72)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.tertiarySystemGroupedBackground))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .accessibilityIdentifier("sticker_\(sticker.name)")
                    }
                }
                .padding(12)
            }
        }
        .accessibilityIdentifier("stickerPackBrowser")
    }
}
