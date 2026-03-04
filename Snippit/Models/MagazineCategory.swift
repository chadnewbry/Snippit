import Foundation

/// Categories for filtering magazines from the Internet Archive Magazine Rack.
enum MagazineCategory: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case fashion = "Fashion"
    case nature = "Nature"
    case science = "Science"
    case art = "Art"
    case vintageAds = "Vintage Ads"

    var id: String { rawValue }

    var searchQuery: String {
        switch self {
        case .all: return ""
        case .fashion: return "subject:(fashion OR vogue OR style OR clothing)"
        case .nature: return "subject:(nature OR wildlife OR outdoors OR national geographic)"
        case .science: return "subject:(science OR scientific OR technology OR popular science)"
        case .art: return "subject:(art OR design OR illustration OR photography)"
        case .vintageAds: return "subject:(advertising OR ads OR advertisement OR commercial)"
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .fashion: return "tshirt"
        case .nature: return "leaf"
        case .science: return "atom"
        case .art: return "paintpalette"
        case .vintageAds: return "megaphone"
        }
    }
}

enum MagazineDecade: String, CaseIterable, Identifiable, Sendable {
    case any = "Any"
    case twenties = "1920s"
    case thirties = "1930s"
    case forties = "1940s"
    case fifties = "1950s"
    case sixties = "1960s"
    case seventies = "1970s"
    case eighties = "1980s"
    case nineties = "1990s"

    var id: String { rawValue }

    var dateRange: (start: String, end: String)? {
        switch self {
        case .any: return nil
        case .twenties: return ("1920-01-01", "1929-12-31")
        case .thirties: return ("1930-01-01", "1939-12-31")
        case .forties: return ("1940-01-01", "1949-12-31")
        case .fifties: return ("1950-01-01", "1959-12-31")
        case .sixties: return ("1960-01-01", "1969-12-31")
        case .seventies: return ("1970-01-01", "1979-12-31")
        case .eighties: return ("1980-01-01", "1989-12-31")
        case .nineties: return ("1990-01-01", "1999-12-31")
        }
    }
}
