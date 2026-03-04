import SwiftUI

/// Grid of bookmarked pages for later clipping.
struct BookmarkedPagesView: View {
    let bookmarks: [BookmarkedPage]

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

    var body: some View {
        if !bookmarks.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Bookmarked Pages")
                        .font(.title3.weight(.bold))
                    Spacer()
                    Text("\(bookmarks.count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                }
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(bookmarks) { bookmark in
                        VStack(spacing: 4) {
                            AsyncImage(url: bookmark.imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(0.7, contentMode: .fill)
                                default:
                                    Color(.systemGray5)
                                        .overlay {
                                            Image(systemName: "bookmark.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                }
                            }
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(bookmark.magazineTitle)
                                .font(.caption2)
                                .lineLimit(1)

                            Text("Page \(bookmark.pageNumber + 1)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    BookmarkedPagesView(bookmarks: BookmarkedPage.previewList)
}
