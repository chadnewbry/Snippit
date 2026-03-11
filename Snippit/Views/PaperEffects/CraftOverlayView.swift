import SwiftUI

/// Renders a decorative craft overlay (washi tape, push pin, paper clip, staple) on top of a clipped item.
struct CraftOverlayView: View {
    let overlayType: CraftOverlayType
    let itemSize: CGSize
    let seed: Int

    var body: some View {
        switch overlayType {
        case .washiTape:
            washiTapeOverlay
        case .pushPin:
            pushPinOverlay
        case .paperClip:
            paperClipOverlay
        case .staple:
            stapleOverlay
        }
    }

    // MARK: - Washi Tape

    private var washiTapeOverlay: some View {
        let tapeWidth = min(itemSize.width * 0.6, 120.0)
        let tapeHeight: CGFloat = 24
        let colors: [Color] = [.pink, .mint, .yellow, .orange, .purple, .cyan]
        var rng = SeededRandomGenerator(seed: UInt64(seed &+ 101))
        let colorIndex = Int.random(in: 0..<colors.count, using: &rng)
        let rotation = Double.random(in: -0.2...0.2, using: &rng)

        return Rectangle()
            .fill(colors[colorIndex].opacity(0.55))
            .frame(width: tapeWidth, height: tapeHeight)
            .overlay {
                // Tape texture: horizontal stripes
                VStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 1)
                    }
                }
            }
            .rotationEffect(.radians(rotation))
            .offset(y: -itemSize.height / 2 - tapeHeight / 4)
            .allowsHitTesting(false)
    }

    // MARK: - Push Pin

    private var pushPinOverlay: some View {
        var rng = SeededRandomGenerator(seed: UInt64(seed &+ 202))
        let offsetX = CGFloat.random(in: -itemSize.width * 0.3...itemSize.width * 0.3, using: &rng)
        let pinColors: [Color] = [.red, .blue, .green, .yellow, .orange]
        let colorIndex = Int.random(in: 0..<pinColors.count, using: &rng)

        return ZStack {
            // Pin shadow
            Circle()
                .fill(.black.opacity(0.2))
                .frame(width: 16, height: 16)
                .offset(x: 1, y: 2)

            // Pin head
            Circle()
                .fill(pinColors[colorIndex])
                .frame(width: 14, height: 14)
                .overlay {
                    Circle()
                        .fill(.white.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .offset(x: -2, y: -2)
                }

            // Pin point
            Circle()
                .fill(.gray)
                .frame(width: 3, height: 3)
        }
        .offset(x: offsetX, y: -itemSize.height / 2 + 6)
        .allowsHitTesting(false)
    }

    // MARK: - Paper Clip

    private var paperClipOverlay: some View {
        var rng = SeededRandomGenerator(seed: UInt64(seed &+ 303))
        let isLeft = Bool.random(using: &rng)
        let rotation = Double.random(in: -0.3...0.3, using: &rng)
        let clipColors: [Color] = [Color(white: 0.75), .red, .blue, .green, .yellow]
        let colorIndex = Int.random(in: 0..<clipColors.count, using: &rng)

        return ZStack {
            // Simplified paper clip shape
            RoundedRectangle(cornerRadius: 8)
                .stroke(clipColors[colorIndex], lineWidth: 2.5)
                .frame(width: 12, height: 36)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(clipColors[colorIndex], lineWidth: 2)
                        .frame(width: 8, height: 18)
                        .offset(y: 2)
                }
        }
        .rotationEffect(.radians(rotation))
        .offset(
            x: isLeft ? -itemSize.width / 2 + 8 : itemSize.width / 2 - 8,
            y: -itemSize.height / 2 + 12
        )
        .allowsHitTesting(false)
    }

    // MARK: - Staple

    private var stapleOverlay: some View {
        var rng = SeededRandomGenerator(seed: UInt64(seed &+ 404))
        let offsetX = CGFloat.random(in: -itemSize.width * 0.25...itemSize.width * 0.25, using: &rng)
        let isTop = Bool.random(using: &rng)

        return ZStack {
            // Staple: horizontal bar with two legs
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(white: 0.7))
                .frame(width: 20, height: 2)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .offset(
            x: offsetX,
            y: isTop ? -itemSize.height / 2 + 4 : itemSize.height / 2 - 4
        )
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 40) {
        ForEach(CraftOverlayType.allCases) { type in
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.blue.opacity(0.1))
                    .frame(width: 150, height: 150)
                CraftOverlayView(overlayType: type, itemSize: CGSize(width: 150, height: 150), seed: 42)
            }
            .overlay(alignment: .bottom) {
                Text(type.rawValue)
                    .font(.caption)
                    .offset(y: 20)
            }
        }
    }
    .padding(40)
}
