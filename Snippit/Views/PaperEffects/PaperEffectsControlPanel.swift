import SwiftUI

/// Control panel for adjusting paper effects on a selected clipped item.
struct PaperEffectsControlPanel: View {
    @Bindable var item: ClippedItem
    @State private var selectedTab: EffectTab = .edges

    enum EffectTab: String, CaseIterable {
        case edges = "Edges"
        case aging = "Aging"
        case overlay = "Overlay"
        case curl = "Curl"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Effect", selection: $selectedTab) {
                ForEach(EffectTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    switch selectedTab {
                    case .edges:
                        edgesSection
                    case .aging:
                        agingSection
                    case .overlay:
                        overlaySection
                    case .curl:
                        curlSection
                    }
                }
                .padding(12)
            }
        }
        .frame(maxHeight: 260)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Edges

    private var edgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edge Style")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(EdgeStyle.allCases) { style in
                    Button {
                        item.edgeStyle = style
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: style.icon)
                                .font(.title3)
                            Text(style.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            item.edgeStyle == style
                                ? Color.accentColor.opacity(0.15)
                                : Color.secondary.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(item.edgeStyle == style ? Color.accentColor : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Intensity: \(item.rippedEdgeRoughness, specifier: "%.1f")")
                    .font(.caption)
                Slider(value: $item.rippedEdgeRoughness, in: 0...1)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Fiber Detail: \(item.fiberDetailIntensity, specifier: "%.1f")")
                    .font(.caption)
                Slider(value: $item.fiberDetailIntensity, in: 0...1)
            }
        }
    }

    // MARK: - Aging

    private var agingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aging Effects")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            agingSlider(label: "Yellowing", value: $item.agingYellowing, icon: "sun.max")
            agingSlider(label: "Coffee Stains", value: $item.agingCoffeeStain, icon: "cup.and.saucer")
            agingSlider(label: "Crumple", value: $item.agingCrumpleTexture, icon: "doc.richtext")
            agingSlider(label: "Faded Ink", value: $item.agingFadedInk, icon: "textformat")
        }
    }

    private func agingSlider(label: String, value: Binding<Double>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(label): \(value.wrappedValue, specifier: "%.1f")")
                    .font(.caption)
            }
            Slider(value: value, in: 0...1)
        }
    }

    // MARK: - Overlay

    private var overlaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Craft Overlay")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                // None option
                Button {
                    item.craftOverlay = nil
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                        Text("None")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(item.craftOverlay == nil ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(item.craftOverlay == nil ? Color.accentColor : .clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)

                ForEach(CraftOverlayType.allCases) { type in
                    Button {
                        item.craftOverlay = type
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.title3)
                            Text(type.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(item.craftOverlay == type ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(item.craftOverlay == type ? Color.accentColor : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Curl

    private var curlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Paper Curl", isOn: $item.paperCurlEnabled)
                .font(.caption.weight(.semibold))

            if item.paperCurlEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    curlSlider(label: "Top Left", value: $item.paperCurlTL)
                    curlSlider(label: "Top Right", value: $item.paperCurlTR)
                    curlSlider(label: "Bottom Left", value: $item.paperCurlBL)
                    curlSlider(label: "Bottom Right", value: $item.paperCurlBR)
                }
            }
        }
    }

    private func curlSlider(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(label): \(value.wrappedValue, specifier: "%.1f")")
                .font(.caption)
            Slider(value: value, in: 0...1)
        }
    }
}
