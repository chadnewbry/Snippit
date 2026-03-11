import CoreGraphics
import UIKit

/// Generates procedural paper edge effects, aging, fiber detail, and shadows.
struct PaperEffectsRenderer {

    // MARK: - Edge Path Generation

    /// Generates an edge path around the given rect using the specified style.
    static func edgePath(
        around rect: CGRect,
        style: EdgeStyle,
        seed: Int,
        roughness: Double = 0.5,
        segmentLength: CGFloat = 8
    ) -> CGPath {
        switch style {
        case .roughTear:
            return roughTearPath(around: rect, seed: seed, roughness: roughness, segmentLength: segmentLength)
        case .scissorsCut:
            return scissorsCutPath(around: rect, seed: seed, roughness: roughness, segmentLength: segmentLength)
        case .burntEdge:
            return burntEdgePath(around: rect, seed: seed, roughness: roughness, segmentLength: segmentLength)
        case .tapePatched:
            return roughTearPath(around: rect, seed: seed, roughness: roughness * 0.7, segmentLength: segmentLength)
        case .deckled:
            return deckledPath(around: rect, seed: seed, roughness: roughness, segmentLength: segmentLength)
        case .perforated:
            return perforatedPath(around: rect, seed: seed, segmentLength: segmentLength)
        }
    }

    /// Legacy API — rough tear style.
    static func rippedEdgePath(
        around rect: CGRect,
        seed: Int,
        roughness: Double = 0.5,
        segmentLength: CGFloat = 8
    ) -> CGPath {
        roughTearPath(around: rect, seed: seed, roughness: roughness, segmentLength: segmentLength)
    }

    // MARK: - Style-Specific Paths

    /// Rough tear: irregular jagged displacement along each edge.
    private static func roughTearPath(
        around rect: CGRect,
        seed: Int,
        roughness: Double,
        segmentLength: CGFloat
    ) -> CGPath {
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        let amplitude = segmentLength * CGFloat(roughness) * 1.2
        let path = CGMutablePath()

        let edges = edgeSegments(of: rect)
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
                // Add secondary wobble for fiber-like detail
                let microOffset = CGFloat.random(in: -amplitude * 0.3...amplitude * 0.3, using: &rng)
                let px = start.x + dx * t + nx * (offset + microOffset)
                let py = start.y + dy * t + ny * (offset + microOffset)
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }

        path.closeSubpath()
        return path
    }

    /// Scissors cut: mostly straight with occasional small notches.
    private static func scissorsCutPath(
        around rect: CGRect,
        seed: Int,
        roughness: Double,
        segmentLength: CGFloat
    ) -> CGPath {
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        let amplitude = segmentLength * CGFloat(roughness) * 0.3
        let path = CGMutablePath()

        let edges = edgeSegments(of: rect)
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
                // Scissors: mostly zero offset with occasional small deviations
                let roll = CGFloat.random(in: 0...1, using: &rng)
                let offset: CGFloat = roll > 0.7 ? CGFloat.random(in: -amplitude...amplitude, using: &rng) : 0
                let px = start.x + dx * t + nx * offset
                let py = start.y + dy * t + ny * offset
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }

        path.closeSubpath()
        return path
    }

    /// Burnt edge: deep irregular scallops eaten inward.
    private static func burntEdgePath(
        around rect: CGRect,
        seed: Int,
        roughness: Double,
        segmentLength: CGFloat
    ) -> CGPath {
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        let amplitude = segmentLength * CGFloat(roughness) * 1.5
        let path = CGMutablePath()

        let edges = edgeSegments(of: rect)
        path.move(to: edges[0].0)

        for (start, end) in edges {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = hypot(dx, dy)
            let segments = max(1, Int(length / (segmentLength * 0.7)))
            let nx = -dy / length
            let ny = dx / length

            for i in 1...segments {
                let t = CGFloat(i) / CGFloat(segments)
                // Burnt: bias inward (negative normal direction) with varying depth
                let baseInward = -amplitude * CGFloat.random(in: 0.2...1.0, using: &rng)
                let wobble = CGFloat.random(in: -amplitude * 0.3...amplitude * 0.1, using: &rng)
                let offset = baseInward + wobble
                let px = start.x + dx * t + nx * offset
                let py = start.y + dy * t + ny * offset
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }

        path.closeSubpath()
        return path
    }

    /// Deckled edge: smooth wavy undulations.
    private static func deckledPath(
        around rect: CGRect,
        seed: Int,
        roughness: Double,
        segmentLength: CGFloat
    ) -> CGPath {
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        let amplitude = segmentLength * CGFloat(roughness) * 0.8
        let path = CGMutablePath()

        let edges = edgeSegments(of: rect)
        path.move(to: edges[0].0)

        for (start, end) in edges {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = hypot(dx, dy)
            let segments = max(1, Int(length / segmentLength))
            let nx = -dy / length
            let ny = dx / length
            let phase = CGFloat.random(in: 0...(.pi * 2), using: &rng)
            let freq = CGFloat.random(in: 3...6, using: &rng)

            for i in 1...segments {
                let t = CGFloat(i) / CGFloat(segments)
                let wave = sin(t * freq * .pi + phase) * amplitude
                let px = start.x + dx * t + nx * wave
                let py = start.y + dy * t + ny * wave
                path.addLine(to: CGPoint(x: px, y: py))
            }
        }

        path.closeSubpath()
        return path
    }

    /// Perforated: small circular holes along the edge with straight lines between.
    private static func perforatedPath(
        around rect: CGRect,
        seed: Int,
        segmentLength: CGFloat
    ) -> CGPath {
        let path = CGMutablePath()
        let inset: CGFloat = segmentLength * 0.3
        let holeRadius: CGFloat = segmentLength * 0.2

        // Main rect with slight inset
        path.addRect(rect.insetBy(dx: -1, dy: -1))

        // Add perforation holes along each edge
        let edges = edgeSegments(of: rect)
        for (start, end) in edges {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = hypot(dx, dy)
            let segments = max(1, Int(length / segmentLength))
            let nx = -dy / length
            let ny = dx / length

            for i in 0...segments {
                let t = CGFloat(i) / CGFloat(segments)
                let cx = start.x + dx * t + nx * inset
                let cy = start.y + dy * t + ny * inset
                path.addEllipse(in: CGRect(
                    x: cx - holeRadius,
                    y: cy - holeRadius,
                    width: holeRadius * 2,
                    height: holeRadius * 2
                ))
            }
        }

        return path
    }

    // MARK: - Fiber Detail

    /// Draws paper fiber lines along the edge path for authenticity.
    static func drawFiberDetail(
        in context: CGContext,
        along path: CGPath,
        seed: Int,
        intensity: Double,
        rect: CGRect
    ) {
        guard intensity > 0 else { return }
        var rng = SeededRandomGenerator(seed: UInt64(seed &+ 7919))
        let fiberCount = Int(Double(Int(rect.width + rect.height) / 4) * intensity)

        context.saveGState()
        context.setLineCap(.round)

        let boundingBox = path.boundingBox

        for _ in 0..<fiberCount {
            let x = CGFloat.random(in: boundingBox.minX...boundingBox.maxX, using: &rng)
            let y = CGFloat.random(in: boundingBox.minY...boundingBox.maxY, using: &rng)
            let fiberLength = CGFloat.random(in: 3...12, using: &rng) * CGFloat(intensity)
            let angle = CGFloat.random(in: 0...(.pi * 2), using: &rng)

            // Only draw fibers near edges (within a margin)
            let margin: CGFloat = 15
            let distFromEdge = min(
                min(x - boundingBox.minX, boundingBox.maxX - x),
                min(y - boundingBox.minY, boundingBox.maxY - y)
            )
            guard distFromEdge < margin else { continue }

            let alpha = CGFloat(intensity) * CGFloat.random(in: 0.15...0.5, using: &rng)
            let gray = CGFloat.random(in: 0.6...0.85, using: &rng)
            context.setStrokeColor(UIColor(white: gray, alpha: alpha).cgColor)
            context.setLineWidth(CGFloat.random(in: 0.3...1.0, using: &rng))

            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(
                x: x + cos(angle) * fiberLength,
                y: y + sin(angle) * fiberLength
            ))
            context.strokePath()
        }

        context.restoreGState()
    }

    // MARK: - Aging Effects

    /// Applies aging effects to an image.
    static func applyAgingEffects(to image: UIImage, aging: AgingEffect) -> UIImage {
        guard aging.hasEffects else { return image }

        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: image.size)
            image.draw(in: rect)

            // Yellowing: warm sepia overlay
            if aging.yellowing > 0 {
                ctx.cgContext.setBlendMode(.multiply)
                ctx.cgContext.setFillColor(
                    UIColor(red: 0.95, green: 0.88, blue: 0.72, alpha: CGFloat(aging.yellowing) * 0.4).cgColor
                )
                ctx.cgContext.fill(rect)
                ctx.cgContext.setBlendMode(.normal)
            }

            // Coffee stain: circular gradient splotches
            if aging.coffeeStain > 0 {
                var rng = SeededRandomGenerator(seed: 42)
                let stainCount = max(1, Int(aging.coffeeStain * 4))
                ctx.cgContext.setBlendMode(.multiply)
                for _ in 0..<stainCount {
                    let cx = CGFloat.random(in: rect.width * 0.1...rect.width * 0.9, using: &rng)
                    let cy = CGFloat.random(in: rect.height * 0.1...rect.height * 0.9, using: &rng)
                    let radius = CGFloat.random(in: 20...80, using: &rng) * CGFloat(aging.coffeeStain)

                    let colors: [CGColor] = [
                        UIColor(red: 0.55, green: 0.35, blue: 0.15, alpha: CGFloat(aging.coffeeStain) * 0.25).cgColor,
                        UIColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 0).cgColor
                    ]
                    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1]) {
                        ctx.cgContext.drawRadialGradient(
                            gradient,
                            startCenter: CGPoint(x: cx, y: cy), startRadius: 0,
                            endCenter: CGPoint(x: cx, y: cy), endRadius: radius,
                            options: []
                        )
                    }
                }
                ctx.cgContext.setBlendMode(.normal)
            }

            // Crumple texture: noise pattern overlay
            if aging.crumpleTexture > 0 {
                var rng2 = SeededRandomGenerator(seed: 137)
                ctx.cgContext.setBlendMode(.overlay)
                let step: CGFloat = 4
                var y: CGFloat = 0
                while y < rect.height {
                    var x: CGFloat = 0
                    while x < rect.width {
                        let noise = CGFloat.random(in: 0...1, using: &rng2)
                        if noise > 0.6 {
                            let alpha = CGFloat(aging.crumpleTexture) * (noise - 0.6) * 0.5
                            ctx.cgContext.setFillColor(UIColor(white: noise > 0.8 ? 1.0 : 0.0, alpha: alpha).cgColor)
                            ctx.cgContext.fill(CGRect(x: x, y: y, width: step, height: step))
                        }
                        x += step
                    }
                    y += step
                }
                ctx.cgContext.setBlendMode(.normal)
            }

            // Faded ink: reduce contrast/saturation
            if aging.fadedInk > 0 {
                ctx.cgContext.setBlendMode(.lighten)
                ctx.cgContext.setFillColor(
                    UIColor(white: 1.0, alpha: CGFloat(aging.fadedInk) * 0.35).cgColor
                )
                ctx.cgContext.fill(rect)
                ctx.cgContext.setBlendMode(.normal)
            }
        }
    }

    // MARK: - Burnt Edge Char

    /// Draws darkened/charred color along the edges for burnt style.
    static func drawBurntEdgeChar(
        in context: CGContext,
        path: CGPath,
        rect: CGRect,
        seed: Int,
        roughness: Double
    ) {
        context.saveGState()

        // Create a slightly expanded stroke along the path for the char
        context.addPath(path)
        context.setLineWidth(CGFloat(roughness) * 12)
        context.setStrokeColor(UIColor(red: 0.15, green: 0.08, blue: 0.02, alpha: 0.6).cgColor)
        context.setBlendMode(.multiply)
        context.strokePath()

        // Add some ember-orange glow at edges
        context.addPath(path)
        context.setLineWidth(CGFloat(roughness) * 6)
        context.setStrokeColor(UIColor(red: 0.7, green: 0.3, blue: 0.0, alpha: 0.2).cgColor)
        context.strokePath()

        context.restoreGState()
    }

    // MARK: - Combined Render

    /// Renders image data with full paper effects applied.
    static func applyPaperEffects(
        to imageData: Data,
        seed: Int,
        roughness: Double,
        edgeStyle: EdgeStyle,
        agingEffect: AgingEffect,
        fiberIntensity: Double
    ) -> UIImage? {
        guard var image = UIImage(data: imageData) else { return nil }
        let rect = CGRect(origin: .zero, size: image.size)

        // Apply aging first (operates on the full image)
        image = applyAgingEffects(to: image, aging: agingEffect)

        let path = edgePath(around: rect, style: edgeStyle, seed: seed, roughness: roughness)

        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext

            // Clip to edge path
            if edgeStyle == .perforated {
                // Perforated uses even-odd fill rule for holes
                cgCtx.addPath(path)
                cgCtx.clip(using: .evenOdd)
            } else {
                cgCtx.addPath(path)
                cgCtx.clip()
            }

            // Draw the image
            image.draw(in: rect)

            // Burnt edge char effect
            if edgeStyle == .burntEdge {
                drawBurntEdgeChar(in: cgCtx, path: path, rect: rect, seed: seed, roughness: roughness)
            }

            // Fiber detail along edges
            drawFiberDetail(in: cgCtx, along: path, seed: seed, intensity: fiberIntensity, rect: rect)
        }
    }

    /// Legacy API.
    static func applyRippedEdges(
        to imageData: Data,
        seed: Int,
        roughness: Double
    ) -> UIImage? {
        applyPaperEffects(
            to: imageData,
            seed: seed,
            roughness: roughness,
            edgeStyle: .roughTear,
            agingEffect: .none,
            fiberIntensity: 0.3
        )
    }

    // MARK: - Shadow

    /// Adds a paper shadow beneath a clipping, with optional curl effect.
    static func addPaperShadow(
        to context: CGContext,
        path: CGPath,
        curl: PaperCurlEffect = .none
    ) {
        context.saveGState()

        if curl.enabled {
            // Slightly skew the shadow for curl effect
            let maxIntensity = curl.cornerIntensity.max() ?? 0
            let shadowOffset = CGSize(width: 2 + maxIntensity * 4, height: 3 + maxIntensity * 5)
            let blur: CGFloat = 6 + CGFloat(maxIntensity) * 8
            context.setShadow(
                offset: shadowOffset,
                blur: blur,
                color: UIColor.black.withAlphaComponent(0.3 + CGFloat(maxIntensity) * 0.15).cgColor
            )
        } else {
            context.setShadow(
                offset: CGSize(width: 2, height: 3),
                blur: 6,
                color: UIColor.black.withAlphaComponent(0.3).cgColor
            )
        }

        context.addPath(path)
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
        context.restoreGState()
    }

    // MARK: - Helpers

    private static func edgeSegments(of rect: CGRect) -> [(CGPoint, CGPoint)] {
        [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY)),
        ]
    }
}

// MARK: - Seeded RNG

struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
