import SwiftUI

/// Main magazine browser with search, category filtering, curated collections, and cover grid.
struct MagazineBrowserView: View {
    @State private var magazineManager = MagazineManager()
    @State private var historyManager = BrowsingHistoryManager()

    @State private var searchText = ""
    @State private var selectedCategory: MagazineCategory = .all
    @State private var selectedDecade: MagazineDecade = .any
    @State private var selectedMagazine: MagazineItem?
    @State private var selectedCollection: CuratedCollection?
    @State private var showingSuggestions = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Search with typeahead
                    searchSection

                    // Category pills
                    CategoryFilterBar(selected: $selectedCategory)

                    // Decade filter
                    DecadeFilterBar(selected: $selectedDecade)

                    // Curated collections (only on initial/unfiltered view)
                    if searchText.isEmpty && selectedCategory == .all && selectedDecade == .any {
                        CuratedCollectionRow(collections: CuratedCollection.featured) { collection in
                            selectedCollection = collection
                        }

                        RecentlyBrowsedRow(magazines: historyManager.recentlyBrowsed) { magazine in
                            selectedMagazine = magazine
                        }

                        BookmarkedPagesView(bookmarks: historyManager.bookmarkedPages)
                    }

                    // Magazine grid
                    magazineGrid
                }
                .padding(.vertical)
            }
            .navigationTitle("Magazine Browser")
            .navigationDestination(item: $selectedMagazine) { magazine in
                MagazineReaderView(
                    magazine: magazine,
                    magazineManager: magazineManager,
                    historyManager: historyManager
                )
            }
            .navigationDestination(item: $selectedCollection) { collection in
                CollectionDetailView(
                    collection: collection,
                    magazineManager: magazineManager,
                    historyManager: historyManager
                )
            }
            .task {
                await magazineManager.search()
            }
            .onChange(of: selectedCategory) {
                Task { await performSearch() }
            }
            .onChange(of: selectedDecade) {
                Task { await performSearch() }
            }
        }
        .accessibilityIdentifier("magazineBrowserTab")
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search magazines...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onSubmit { Task { await performSearch() } }
                    .onChange(of: searchText) {
                        Task { await magazineManager.fetchSuggestions(for: searchText) }
                        showingSuggestions = !searchText.isEmpty
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        showingSuggestions = false
                        Task { await performSearch() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            // Typeahead suggestions
            if showingSuggestions && !magazineManager.searchSuggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(magazineManager.searchSuggestions, id: \.self) { suggestion in
                        Button {
                            searchText = suggestion
                            showingSuggestions = false
                            Task { await performSearch() }
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(suggestion)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 40)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Magazine Grid

    private var magazineGrid: some View {
        Group {
            if magazineManager.isLoading && magazineManager.magazines.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading magazines...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else if magazineManager.magazines.isEmpty {
                ContentUnavailableView(
                    "No Magazines Found",
                    systemImage: "book.closed",
                    description: Text("Try a different search or category")
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(magazineManager.magazines) { magazine in
                        Button {
                            selectedMagazine = magazine
                        } label: {
                            MagazineCoverCard(magazine: magazine)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            // Infinite scroll
                            if magazine.id == magazineManager.magazines.last?.id {
                                Task {
                                    await magazineManager.loadMore(
                                        query: searchText,
                                        category: selectedCategory,
                                        decade: selectedDecade
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                if magazineManager.isLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
    }

    private func performSearch() async {
        showingSuggestions = false
        await magazineManager.search(query: searchText, category: selectedCategory, decade: selectedDecade)
    }
}

#Preview {
    MagazineBrowserView()
}
