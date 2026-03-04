import SwiftUI

/// Renders text on a paper scrap with ripped edges.
struct TextOnPaperView: View {
    let element: TextElement

    var body: some View {
        Text(element.text)
            .font(.custom(element.fontName, size: element.fontSize))
            .tracking(element.letterSpacing)
            .foregroundStyle(element.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RippedPaperShape(seed: element.paperSeed, roughness: element.paperRoughness)
                    .fill(Color(white: 0.95))
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 2, y: 3)
            }
            .overlay {
                RippedPaperShape(seed: element.paperSeed, roughness: element.paperRoughness)
                    .stroke(Color(white: 0.85), lineWidth: 0.5)
            }
    }
}

/// A shape with procedurally ripped edges, reusing the same algorithm as PaperEffectsRenderer.
struct RippedPaperShape: Shape {
    let seed: Int
    let roughness: Double
    var segmentLength: CGFloat = 6

    func path(in rect: CGRect) -> Path {
        var rng = PaperRNG(seed: UInt64(abs(seed)))
        let amplitude = segmentLength * CGFloat(roughness)
        var path = Path()

        let edges: [(CGPoint, CGPoint)] = [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY)),
        ]

        path.move(to: edges[0].0)

        for (start, end) in edges {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = hypot(dx, dy)
            let segments = max(1, Int(length / segmentLength))
            let nx = -dy / length
            let ny = dx / length

            for i in 1...segments {
                let t = CGFloat(i) / CGFloat(segments)
                let offset = CGFloat.random(in: -amplitude...amplitude, using: &rng)
                let px = start.x + dx * t + nx * offset
                let py = start.y + dy * t + ny * offset
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }

        path.closeSubpath()
        return path
    }
}

private struct PaperRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

#Preview {
    TextOnPaperView(element: TextElement(
        text: "torn paper vibes",
        fontName: "AmericanTypewriter",
        fontSize: 24,
        colorHex: "#333333",
        isTextOnPaper: true,
        paperSeed: 99
    ))
    .padding(40)
    .background(Color.gray.opacity(0.3))
}
