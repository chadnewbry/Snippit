import SwiftUI

struct ShapeStampRendererView: View {
    let shape: ShapeStamp

    var body: some View {
        ZStack {
            shapeContent
                .overlay(
                    shape.hasPaperTexture ? paperTexture : nil
                )
        }
    }

    @ViewBuilder
    private var shapeContent: some View {
        switch shape.type {
        case .circle:
            Circle()
                .fill(shape.fillColor)
                .overlay(Circle().strokeBorder(shape.strokeColor, lineWidth: 1.5))

        case .rectangle:
            RoundedRectangle(cornerRadius: 4)
                .fill(shape.fillColor)
                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(shape.strokeColor, lineWidth: 1.5))

        case .star:
            starPath
                .fill(shape.fillColor)
                .overlay(starPath.stroke(shape.strokeColor, lineWidth: 1.5))

        case .arrow:
            arrowPath
                .fill(shape.fillColor)
                .overlay(arrowPath.stroke(shape.strokeColor, lineWidth: 1.5))

        case .speechBubble:
            speechBubblePath
                .fill(shape.fillColor)
                .overlay(speechBubblePath.stroke(shape.strokeColor, lineWidth: 1.5))
        }
    }

    private var starPath: some Shape {
        StarShape(points: 5, innerRatio: 0.45)
    }

    private var arrowPath: some Shape {
        ArrowShape()
    }

    private var speechBubblePath: some Shape {
        SpeechBubbleShape()
    }

    @ViewBuilder
    private var paperTexture: some View {
        Canvas { context, size in
            for _ in 0..<80 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.03...0.08)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.brown.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Custom Shapes

struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        let totalPoints = points * 2

        var path = Path()
        for i in 0..<totalPoints {
            let angle = (CGFloat(i) / CGFloat(totalPoints)) * 2 * .pi - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Arrow pointing right
        path.move(to: CGPoint(x: 0, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.1))
        path.addLine(to: CGPoint(x: w, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.9))
        path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.7))
        path.addLine(to: CGPoint(x: 0, y: h * 0.7))
        path.closeSubpath()
        return path
    }
}

struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let bubbleH = h * 0.75
        let cornerR: CGFloat = min(w, bubbleH) * 0.15

        // Main bubble
        path.addRoundedRect(
            in: CGRect(x: 0, y: 0, width: w, height: bubbleH),
            cornerSize: CGSize(width: cornerR, height: cornerR)
        )

        // Tail
        path.move(to: CGPoint(x: w * 0.2, y: bubbleH))
        path.addLine(to: CGPoint(x: w * 0.1, y: h))
        path.addLine(to: CGPoint(x: w * 0.4, y: bubbleH))
        path.closeSubpath()

        return path
    }
}
