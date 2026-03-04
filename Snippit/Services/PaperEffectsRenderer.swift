import CoreGraphics
import UIKit

/// Generates procedural ripped/torn paper edge effects for clipped items.
struct PaperEffectsRenderer {
    /// Generates a ripped edge path around the given rect.
    static func rippedEdgePath(
        around rect: CGRect,
        seed: Int,
        roughness: Double = 0.5,
        segmentLength: CGFloat = 8
    ) -> CGPath {
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        let amplitude = segmentLength * CGFloat(roughness)
        let path = CGMutablePath()

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

    /// Renders image data with ripped paper edges applied.
    static func applyRippedEdges(
        to imageData: Data,
        seed: Int,
        roughness: Double
    ) -> UIImage? {
        guard let image = UIImage(data: imageData) else { return nil }
        let rect = CGRect(origin: .zero, size: image.size)
        let edgePath = rippedEdgePath(around: rect, seed: seed, roughness: roughness)

        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            ctx.cgContext.addPath(edgePath)
            ctx.cgContext.clip()
            image.draw(in: rect)
        }
    }

    /// Adds a subtle paper shadow beneath a ripped clipping.
    static func addPaperShadow(to context: CGContext, path: CGPath) {
        context.saveGState()
        context.setShadow(offset: CGSize(width: 2, height: 3), blur: 6, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        context.addPath(path)
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
        context.restoreGState()
    }
}

// MARK: - Seeded RNG

private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
