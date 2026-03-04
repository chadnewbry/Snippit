import SwiftUI

struct GridOverlayView: View {
    let canvasSize: CGSize
    let spacing: CGFloat

    var body: some View {
        Canvas { context, size in
            let color = Color.gray.opacity(0.15)
            var x: CGFloat = 0
            while x <= canvasSize.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
                x += spacing
            }
            var y: CGFloat = 0
            while y <= canvasSize.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
                y += spacing
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .allowsHitTesting(false)
    }
}
