import SwiftUI

struct DoodleStrokeRendererView: View {
    let stroke: DoodleStroke

    var body: some View {
        Canvas { context, _ in
            guard stroke.points.count > 1 else { return }

            var path = Path()
            path.move(to: stroke.points[0])
            for i in 1..<stroke.points.count {
                path.addLine(to: stroke.points[i])
            }

            context.stroke(
                path,
                with: .color(stroke.color.opacity(stroke.brush.opacity)),
                style: StrokeStyle(
                    lineWidth: stroke.lineWidth,
                    lineCap: stroke.brush.lineCap,
                    lineJoin: .round
                )
            )
        }
    }
}
