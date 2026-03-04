import Foundation

/// Represents a magazine from the Internet Archive Magazine Rack.
struct MagazineItem: Identifiable, Codable, Hashable, Sendable {
    let identifier: String
    let title: String
    let description: String?
    let date: String?
    let coverURL: URL?
    let pageCount: Int?

    var id: String { identifier }
}

/// A single page image from a magazine.
struct MagazinePage: Identifiable, Sendable {
    let magazineIdentifier: String
    let pageNumber: Int
    let imageURL: URL

    var id: String { "\(magazineIdentifier)-\(pageNumber)" }
}

#if DEBUG
extension MagazineItem: PreviewData {
    static var preview: MagazineItem {
        MagazineItem(
            identifier: "sim_vogue_1950-01",
            title: "Vogue - January 1950",
            description: "The fashion bible's January issue featuring spring collections",
            date: "1950-01-01",
            coverURL: URL(string: "https://archive.org/services/img/sim_vogue_1950-01"),
            pageCount: 120
        )
    }

    static var previewList: [MagazineItem] {
        [
            preview,
            MagazineItem(identifier: "sim_life_1955-06", title: "Life - June 1955", description: "America's favorite picture magazine", date: "1955-06-01", coverURL: URL(string: "https://archive.org/services/img/sim_life_1955-06"), pageCount: 96),
            MagazineItem(identifier: "sim_popular-science_1960-03", title: "Popular Science - March 1960", description: "The future is now", date: "1960-03-01", coverURL: URL(string: "https://archive.org/services/img/sim_popular-science_1960-03"), pageCount: 84),
            MagazineItem(identifier: "sim_national-geographic_1965-09", title: "National Geographic - September 1965", description: "Exploring the world", date: "1965-09-01", coverURL: URL(string: "https://archive.org/services/img/sim_national-geographic_1965-09"), pageCount: 140),
            MagazineItem(identifier: "sim_saturday-evening-post_1948-12", title: "Saturday Evening Post - December 1948", description: "Norman Rockwell holiday issue", date: "1948-12-01", coverURL: URL(string: "https://archive.org/services/img/sim_saturday-evening-post_1948-12"), pageCount: 72),
        ]
    }
}
#endif
