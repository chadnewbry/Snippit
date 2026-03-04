import Foundation

/// A bookmarked magazine page saved for later clipping.
struct BookmarkedPage: Identifiable, Codable, Sendable {
    let id: UUID
    let magazineIdentifier: String
    let magazineTitle: String
    let pageNumber: Int
    let imageURL: URL
    let bookmarkedAt: Date

    init(id: UUID = UUID(), magazineIdentifier: String, magazineTitle: String, pageNumber: Int, imageURL: URL, bookmarkedAt: Date = Date()) {
        self.id = id
        self.magazineIdentifier = magazineIdentifier
        self.magazineTitle = magazineTitle
        self.pageNumber = pageNumber
        self.imageURL = imageURL
        self.bookmarkedAt = bookmarkedAt
    }

    init(magazine: MagazineItem, page: MagazinePage) {
        self.init(
            magazineIdentifier: magazine.identifier,
            magazineTitle: magazine.title,
            pageNumber: page.pageNumber,
            imageURL: page.imageURL
        )
    }
}

#if DEBUG
extension BookmarkedPage: PreviewData {
    static var preview: BookmarkedPage {
        BookmarkedPage(
            magazineIdentifier: "sim_vogue_1950-01",
            magazineTitle: "Vogue - January 1950",
            pageNumber: 3,
            imageURL: URL(string: "https://archive.org/download/sim_vogue_1950-01/page3.jpg")!
        )
    }

    static var previewList: [BookmarkedPage] {
        [
            preview,
            BookmarkedPage(
                magazineIdentifier: "sim_life_1955-06",
                magazineTitle: "Life - June 1955",
                pageNumber: 12,
                imageURL: URL(string: "https://archive.org/download/sim_life_1955-06/page12.jpg")!,
                bookmarkedAt: Date().addingTimeInterval(-3600)
            ),
            BookmarkedPage(
                magazineIdentifier: "sim_popular-science_1960-03",
                magazineTitle: "Popular Science - March 1960",
                pageNumber: 7,
                imageURL: URL(string: "https://archive.org/download/sim_popular-science_1960-03/page7.jpg")!,
                bookmarkedAt: Date().addingTimeInterval(-7200)
            ),
        ]
    }
}
#endif
