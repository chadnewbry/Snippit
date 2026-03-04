import SwiftUI

struct CollageCanvasView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "rectangle.on.rectangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Collage Canvas")
                    .font(.title2)
            }
            .navigationTitle("Collage Canvas")
        }
        .accessibilityIdentifier("collageCanvasTab")
    }
}

#Preview {
    CollageCanvasView()
}
