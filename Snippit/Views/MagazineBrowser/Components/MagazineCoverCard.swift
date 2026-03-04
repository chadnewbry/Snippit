import SwiftUI

/// A magazine cover card for the grid view.
struct MagazineCoverCard: View {
    let magazine: MagazineItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: magazine.coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(0.7, contentMode: .fill)
                        .clipped()
                case .failure:
                    placeholder
                case .empty:
                    placeholder
                        .overlay { ProgressView() }
                @unknown default:
                    placeholder
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            Text(magazine.title)
                .font(.caption.weight(.medium))
                .lineLimit(2)
                .foregroundStyle(.primary)

            if let date = magazine.date?.prefix(4) {
                Text(String(date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("magazineCover-\(magazine.identifier)")
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray5))
            .aspectRatio(0.7, contentMode: .fill)
            .overlay {
                Image(systemName: "book.closed")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    MagazineCoverCard(magazine: .preview)
        .frame(width: 160)
}
