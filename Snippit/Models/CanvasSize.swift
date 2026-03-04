import CoreGraphics
import Foundation

enum CanvasSize: String, CaseIterable, Identifiable {
    case square = "1:1"
    case portrait = "4:5"
    case story = "9:16"
    case landscape = "16:9"
    case a4 = "A4"
    case letter = "Letter"

    var id: String { rawValue }

    var dimensions: CGSize {
        switch self {
        case .square: CGSize(width: 1080, height: 1080)
        case .portrait: CGSize(width: 1080, height: 1350)
        case .story: CGSize(width: 1080, height: 1920)
        case .landscape: CGSize(width: 1920, height: 1080)
        case .a4: CGSize(width: 2480, height: 3508)
        case .letter: CGSize(width: 2550, height: 3300)
        }
    }

    var icon: String {
        switch self {
        case .square: "square"
        case .portrait: "rectangle.portrait"
        case .story: "iphone"
        case .landscape: "rectangle"
        case .a4: "doc"
        case .letter: "doc.text"
        }
    }
}
