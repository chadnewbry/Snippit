import SwiftData
import SwiftUI

struct ProjectCardView: View {
    let project: CollageProject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(project.canvasWidth / project.canvasHeight, contentMode: .fit)
                .overlay {
                    if project.layers.isEmpty {
                        VStack(spacing: 4) {
                            Image(systemName: "scissors")
                                .font(.title2)
                            Text("Empty Canvas")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        Text("\(project.layers.count) layers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(project.modifiedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("projectCard-\(project.name)")
    }
}
