import SwiftUI

struct ShapeStampPickerView: View {
    let onShapeSelected: (ShapeStamp) -> Void

    @State private var selectedType: ShapeStampType = .circle
    @State private var fillColor: Color = Color(red: 0.95, green: 0.91, blue: 0.82)
    @State private var strokeColor: Color = Color(red: 0.35, green: 0.25, blue: 0.20)
    @State private var hasPaperTexture = true
    @State private var shapeSize: CGFloat = 100

    private let fillPresets: [Color] = [
        Color(red: 0.95, green: 0.91, blue: 0.82), // Parchment
        Color(red: 0.76, green: 0.64, blue: 0.48), // Kraft
        Color(red: 0.98, green: 0.96, blue: 0.90), // Cream
        Color(red: 0.82, green: 0.55, blue: 0.60), // Dusty Rose
        Color(red: 0.55, green: 0.75, blue: 0.65), // Sage
        Color(red: 0.85, green: 0.75, blue: 0.50), // Mustard
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Shape type selector
            HStack(spacing: 10) {
                ForEach(ShapeStampType.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.system(size: 9))
                                .lineLimit(1)
                        }
                        .frame(width: 58, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedType == type
                                    ? Color(red: 0.82, green: 0.55, blue: 0.60).opacity(0.3)
                                    : Color(.tertiarySystemGroupedBackground))
                        )
                        .foregroundStyle(selectedType == type
                            ? Color(red: 0.65, green: 0.16, blue: 0.16)
                            : .secondary)
                    }
                    .accessibilityIdentifier("shapeType_\(type.rawValue)")
                }
            }
            .padding(.horizontal, 12)

            // Preview & options
            HStack(spacing: 16) {
                // Shape preview
                ShapeStampRendererView(shape: ShapeStamp(
                    type: selectedType,
                    size: CGSize(width: shapeSize, height: shapeSize),
                    fillColor: fillColor,
                    strokeColor: strokeColor,
                    hasPaperTexture: hasPaperTexture
                ))
                .frame(width: 80, height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )

                VStack(alignment: .leading, spacing: 8) {
                    // Fill color presets
                    HStack(spacing: 6) {
                        Text("Fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .leading)
                        ForEach(Array(fillPresets.enumerated()), id: \.offset) { idx, color in
                            Button {
                                fillColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color(red: 0.35, green: 0.25, blue: 0.20).opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .accessibilityIdentifier("shapeFill_\(idx)")
                        }
                    }

                    // Paper texture toggle
                    Toggle(isOn: $hasPaperTexture) {
                        Text("Paper texture")
                            .font(.caption)
                    }
                    .toggleStyle(.switch)
                    .tint(Color(red: 0.70, green: 0.45, blue: 0.20))
                    .accessibilityIdentifier("paperTextureToggle")

                    // Size slider
                    HStack {
                        Text("Size")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Slider(value: $shapeSize, in: 40...200, step: 10)
                            .tint(Color(red: 0.70, green: 0.45, blue: 0.20))
                            .accessibilityIdentifier("shapeSizeSlider")
                    }
                }
            }
            .padding(.horizontal, 12)

            // Add button
            Button {
                let shape = ShapeStamp(
                    type: selectedType,
                    size: CGSize(width: shapeSize, height: shapeSize),
                    fillColor: fillColor,
                    strokeColor: strokeColor,
                    hasPaperTexture: hasPaperTexture
                )
                onShapeSelected(shape)
            } label: {
                Text("Add Shape")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.65, green: 0.16, blue: 0.16))
                    )
            }
            .padding(.horizontal, 12)
            .accessibilityIdentifier("addShapeButton")
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("shapeStampPicker")
    }
}
