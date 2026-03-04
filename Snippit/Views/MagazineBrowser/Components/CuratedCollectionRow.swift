import SwiftUI

/// A horizontal scrolling row of curated collection cards.
struct CuratedCollectionRow: View {
    let collections: [CuratedCollection]
    let onSelect: (CuratedCollection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Curated Collections")
                .font(.title3.weight(.bold))
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(collections) { collection in
                        Button { onSelect(collection) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: collection.iconName)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                Text(collection.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)

                                Text(collection.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .frame(width: 150, alignment: .leading)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    CuratedCollectionRow(collections: CuratedCollection.featured) { _ in }
}
