import Foundation

/// A curated collection of magazines for browsing.
struct CuratedCollection: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let searchQuery: String
    let iconName: String

    static let featured: [CuratedCollection] = [
        CuratedCollection(
            id: "vintage-fashion",
            title: "Best of Vintage Fashion",
            description: "Iconic fashion magazines from the golden age",
            searchQuery: "collection:magazinerack subject:(fashion OR vogue) AND date:[1940-01-01 TO 1969-12-31]",
            iconName: "tshirt.fill"
        ),
        CuratedCollection(
            id: "retro-ads",
            title: "Retro Ads",
            description: "Classic advertisements that defined an era",
            searchQuery: "collection:magazinerack subject:(advertising OR ads) AND date:[1950-01-01 TO 1979-12-31]",
            iconName: "megaphone.fill"
        ),
        CuratedCollection(
            id: "mid-century-science",
            title: "Mid-Century Science",
            description: "The atomic age through magazine covers",
            searchQuery: "collection:magazinerack subject:(science OR scientific) AND date:[1945-01-01 TO 1969-12-31]",
            iconName: "atom"
        ),
        CuratedCollection(
            id: "nature-wildlife",
            title: "Nature & Wildlife",
            description: "Stunning nature photography and illustrations",
            searchQuery: "collection:magazinerack subject:(nature OR wildlife OR national geographic)",
            iconName: "leaf.fill"
        ),
        CuratedCollection(
            id: "art-illustration",
            title: "Art & Illustration",
            description: "Magazine art at its finest",
            searchQuery: "collection:magazinerack subject:(art OR illustration OR design)",
            iconName: "paintbrush.fill"
        ),
        CuratedCollection(
            id: "pulp-covers",
            title: "Pulp Magazine Covers",
            description: "Bold, colorful pulp magazine artwork",
            searchQuery: "collection:magazinerack subject:(pulp OR fiction OR adventure) AND date:[1920-01-01 TO 1959-12-31]",
            iconName: "flame.fill"
        ),
    ]
}

#if DEBUG
extension CuratedCollection: PreviewData {
    static var preview: CuratedCollection { featured[0] }
    static var previewList: [CuratedCollection] { Array(featured.prefix(4)) }
}
#endif
