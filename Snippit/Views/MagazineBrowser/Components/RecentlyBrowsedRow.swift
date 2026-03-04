import SwiftUI

/// Horizontal row showing recently browsed magazines.
struct RecentlyBrowsedRow: View {
    let magazines: [MagazineItem]
    let onSelect: (MagazineItem) -> Void

    var body: some View {
        if !magazines.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recently Browsed")
                    .font(.title3.weight(.bold))
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(magazines) { magazine in
                            Button { onSelect(magazine) } label: {
                                VStack(spacing: 6) {
                                    AsyncImage(url: magazine.coverURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(0.7, contentMode: .fill)
                                        default:
                                            Color(.systemGray5)
                                                .overlay {
                                                    Image(systemName: "book.closed")
                                                        .foregroundStyle(.secondary)
                                                }
                                        }
                                    }
                                    .frame(width: 90, height: 128)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                                    Text(magazine.title)
                                        .font(.caption2)
                                        .lineLimit(1)
                                        .frame(width: 90)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    RecentlyBrowsedRow(magazines: MagazineItem.previewList) { _ in }
}
