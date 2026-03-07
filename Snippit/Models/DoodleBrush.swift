import SwiftUI

// MARK: - Brush Types

enum BrushType: String, CaseIterable, Identifiable {
    case pen = "Pen"
    case marker = "Marker"
    case highlighter = "Highlighter"
    case crayon = "Crayon"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .marker: return "paintbrush.pointed.fill"
        case .highlighter: return "highlighter"
        case .crayon: return "scribble.variable"
        }
    }

    var defaultWidth: CGFloat {
        switch self {
        case .pen: return 2
        case .marker: return 6
        case .highlighter: return 20
        case .crayon: return 8
        }
    }

    var opacity: Double {
        switch self {
        case .pen: return 1.0
        case .marker: return 0.85
        case .highlighter: return 0.35
        case .crayon: return 0.75
        }
    }

    var lineCap: CGLineCap {
        switch self {
        case .pen: return .round
        case .marker: return .square
        case .highlighter: return .butt
        case .crayon: return .round
        }
    }
}

// MARK: - Doodle Stroke

struct DoodleStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var brush: BrushType
    var color: Color
    var lineWidth: CGFloat

    init(points: [CGPoint] = [], brush: BrushType = .pen, color: Color = .black, lineWidth: CGFloat? = nil) {
        self.points = points
        self.brush = brush
        self.color = color
        self.lineWidth = lineWidth ?? brush.defaultWidth
    }
}

// MARK: - Doodle Color Palette

struct DoodleColorPalette {
    static let scrapbookColors: [Color] = [
        .black,
        Color(red: 0.35, green: 0.25, blue: 0.20),  // Sepia
        Color(red: 0.65, green: 0.16, blue: 0.16),   // Vintage Red
        Color(red: 0.13, green: 0.37, blue: 0.31),   // Forest
        Color(red: 0.25, green: 0.31, blue: 0.55),   // Navy
        Color(red: 0.70, green: 0.45, blue: 0.20),   // Amber
        Color(red: 0.55, green: 0.27, blue: 0.52),   // Plum
        Color(red: 0.82, green: 0.55, blue: 0.60),   // Dusty Rose
        Color(red: 0.45, green: 0.60, blue: 0.55),   // Sage
        Color(red: 0.85, green: 0.65, blue: 0.35),   // Mustard
    ]
}
