import SwiftUI

// MARK: - Shape Types

enum ShapeStampType: String, CaseIterable, Identifiable {
    case circle = "Circle"
    case rectangle = "Rectangle"
    case star = "Star"
    case arrow = "Arrow"
    case speechBubble = "Speech Bubble"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .circle: return "circle"
        case .rectangle: return "rectangle"
        case .star: return "star"
        case .arrow: return "arrow.right"
        case .speechBubble: return "bubble.left"
        }
    }
}

// MARK: - Shape Stamp

struct ShapeStamp: Identifiable {
    let id = UUID()
    var type: ShapeStampType
    var size: CGSize
    var fillColor: Color
    var strokeColor: Color
    var hasPaperTexture: Bool

    init(
        type: ShapeStampType,
        size: CGSize = CGSize(width: 100, height: 100),
        fillColor: Color = Color(red: 0.95, green: 0.91, blue: 0.82),
        strokeColor: Color = Color(red: 0.35, green: 0.25, blue: 0.20),
        hasPaperTexture: Bool = true
    ) {
        self.type = type
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.hasPaperTexture = hasPaperTexture
    }
}
