import Foundation

/// Manages recently browsed magazines and bookmarked pages, persisting to UserDefaults.
@Observable
final class BrowsingHistoryManager {
    private(set) var recentlyBrowsed: [MagazineItem] = []
    private(set) var bookmarkedPages: [BookmarkedPage] = []

    private let defaults: UserDefaults
    private let recentKey = "snippit.recentlyBrowsed"
    private let bookmarksKey = "snippit.bookmarkedPages"
    private let maxRecent = 20

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadRecent()
        loadBookmarks()
    }

    // MARK: - Recently Browsed

    func recordBrowsed(_ magazine: MagazineItem) {
        recentlyBrowsed.removeAll { $0.identifier == magazine.identifier }
        recentlyBrowsed.insert(magazine, at: 0)
        if recentlyBrowsed.count > maxRecent {
            recentlyBrowsed = Array(recentlyBrowsed.prefix(maxRecent))
        }
        saveRecent()
    }

    // MARK: - Bookmarks

    func toggleBookmark(magazine: MagazineItem, page: MagazinePage) {
        if let index = bookmarkedPages.firstIndex(where: {
            $0.magazineIdentifier == magazine.identifier && $0.pageNumber == page.pageNumber
        }) {
            bookmarkedPages.remove(at: index)
        } else {
            bookmarkedPages.insert(BookmarkedPage(magazine: magazine, page: page), at: 0)
        }
        saveBookmarks()
    }

    func isBookmarked(magazineIdentifier: String, pageNumber: Int) -> Bool {
        bookmarkedPages.contains { $0.magazineIdentifier == magazineIdentifier && $0.pageNumber == pageNumber }
    }

    // MARK: - Persistence

    private func loadRecent() {
        guard let data = defaults.data(forKey: recentKey),
              let items = try? JSONDecoder().decode([MagazineItem].self, from: data) else { return }
        recentlyBrowsed = items
    }

    private func saveRecent() {
        if let data = try? JSONEncoder().encode(recentlyBrowsed) {
            defaults.set(data, forKey: recentKey)
        }
    }

    private func loadBookmarks() {
        guard let data = defaults.data(forKey: bookmarksKey),
              let items = try? JSONDecoder().decode([BookmarkedPage].self, from: data) else { return }
        bookmarkedPages = items
    }

    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarkedPages) {
            defaults.set(data, forKey: bookmarksKey)
        }
    }
}
