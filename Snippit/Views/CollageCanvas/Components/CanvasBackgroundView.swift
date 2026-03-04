import SwiftUI

struct CanvasBackgroundView: View {
    let style: CanvasBackgroundStyle
    let size: CGSize

    var body: some View {
        Group {
            if let secondary = style.secondaryColor {
                LinearGradient(
                    colors: [style.primaryColor, secondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                style.primaryColor
            }
        }
        .frame(width: size.width, height: size.height)
        .overlay {
            if style.hasTexture {
                TextureOverlay(style: style)
            }
        }
    }
}

private struct TextureOverlay: View {
    let style: CanvasBackgroundStyle

    var body: some View {
        Canvas { context, size in
            // Procedural noise texture for paper effects
            var rng = StableRNG(seed: style.rawValue.hashValue)
            let dotSize: CGFloat = 2
            let step: CGFloat = 4

            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let opacity = Double.random(in: 0.02...0.08, using: &rng)
                    let dark = Bool.random(using: &rng)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                        with: .color(dark ? .black.opacity(opacity) : .white.opacity(opacity))
                    )
                    x += step
                }
                y += step
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StableRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(bitPattern: Int64(seed))
        if state == 0 { state = 1 }
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
