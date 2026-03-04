import SwiftData
import SwiftUI

struct IngredientsTrayView: View {
    @Query(sort: \ClippedItem.createdAt, order: .reverse)
    private var clippedItems: [ClippedItem]

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Button {
                withAnimation(.spring(response: 0.35)) {
                    isExpanded.toggle()
                }
            } label: {
                VStack(spacing: 4) {
                    Capsule()
                        .fill(.secondary.opacity(0.4))
                        .frame(width: 36, height: 4)
                        .padding(.top, 8)

                    HStack {
                        Image(systemName: "tray.full.fill")
                        Text("Ingredients")
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text("\(clippedItems.count) items")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("ingredientsTrayHandle")

            if isExpanded {
                if clippedItems.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "scissors")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No clippings yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Browse magazines and clip items to collect them here")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(clippedItems) { item in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.purple.opacity(0.2))
                                    .frame(width: 64, height: 64)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
    }
}
