import SwiftUI

/// Bottom toolbar for switching between clipping tools.
struct ClippingToolbar: View {
    @Bindable var viewModel: SmartClippingViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Refine controls (visible when refine tool active)
            if viewModel.activeTool == .refine {
                HStack(spacing: 16) {
                    Picker("Mode", selection: $viewModel.refineMode) {
                        Label("Add", systemImage: "plus.circle").tag(SmartClippingViewModel.RefineMode.add)
                        Label("Subtract", systemImage: "minus.circle").tag(SmartClippingViewModel.RefineMode.subtract)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)

                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption2)
                        Slider(value: $viewModel.refineBrushSize, in: 5...50)
                            .frame(maxWidth: 120)
                        Image(systemName: "circle.fill")
                            .font(.body)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            // Main tool buttons
            HStack(spacing: 0) {
                ForEach(SmartClippingViewModel.ClippingTool.allCases) { tool in
                    Button {
                        viewModel.activeTool = tool
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tool.icon)
                                .font(.title3)
                            Text(tool.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.activeTool == tool
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                    .foregroundStyle(viewModel.activeTool == tool ? .primary : .secondary)
                }

                Divider().frame(height: 30).padding(.horizontal, 4)

                // Auto-detect all
                Button {
                    Task { await viewModel.autoDetectAllElements() }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                        Text("Auto")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ClippingToolbar(viewModel: SmartClippingViewModel())
}
