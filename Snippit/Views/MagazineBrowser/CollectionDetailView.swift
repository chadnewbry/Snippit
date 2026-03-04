import SwiftUI

/// Shows magazines from a curated collection.
struct CollectionDetailView: View {
    let collection: CuratedCollection
    let magazineManager: MagazineManager
    let historyManager: BrowsingHistoryManager

    @State private var selectedMagazine: MagazineItem?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: collection.iconName)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.title)
                            .font(.title2.weight(.bold))
                        Text(collection.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Magazine grid
                if magazineManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(magazineManager.magazines) { magazine in
                            Button {
                                selectedMagazine = magazine
                            } label: {
                                MagazineCoverCard(magazine: magazine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedMagazine) { magazine in
            MagazineReaderView(
                magazine: magazine,
                magazineManager: magazineManager,
                historyManager: historyManager
            )
        }
        .task {
            await magazineManager.searchCollection(collection)
        }
    }
}
