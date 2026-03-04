import SwiftData
import SwiftUI

struct CanvasIngredientsTrayView: View {
    @Query(sort: \ClippedItem.createdAt, order: .reverse)
    private var allClippedItems: [ClippedItem]

    let onDrop: (ClippedItem) -> Void

    @State private var isExpanded = false

    /// Items not yet assigned to a project (available as ingredients)
    private var availableItems: [ClippedItem] {
        allClippedItems.filter { $0.project == nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: "tray.full.fill")
                    Text("Ingredients")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(availableItems.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("canvasIngredientsTrayHandle")

            if isExpanded {
                if availableItems.isEmpty {
                    Text("No ingredients available")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableItems) { item in
                                ingredientThumbnail(item)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func ingredientThumbnail(_ item: ClippedItem) -> some View {
        Group {
            if let img = UIImage(data: item.imageData) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3), lineWidth: 0.5))
        .shadow(radius: 2)
        .onTapGesture { onDrop(item) }
        .draggable(item.imageData) // For drag-and-drop support
    }
}
