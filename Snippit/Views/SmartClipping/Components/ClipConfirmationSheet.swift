import SwiftUI

/// Confirmation sheet showing clipped items with ripped-paper edge preview option.
struct ClipConfirmationSheet: View {
    @Bindable var viewModel: SmartClippingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("\(viewModel.clippedRegions.count) element\(viewModel.clippedRegions.count == 1 ? "" : "s") selected")
                        .font(.headline)

                    LazyVGrid(columns: [.init(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.clippedRegions) { region in
                            ClipPreviewCard(region: region) {
                                viewModel.toggleRippedEdge(for: region.id)
                            } onRemove: {
                                viewModel.removeRegion(region)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Clip It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Collage") {
                        _ = viewModel.exportClippedItems()
                        dismiss()
                        viewModel.reset()
                    }
                    .bold()
                }
            }
        }
    }
}

/// Individual preview card for a clipped element.
struct ClipPreviewCard: View {
    let region: SmartClippingViewModel.ClippedRegion
    let onToggleEdge: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if region.useRippedEdge {
                    // Show with ripped paper edge preview
                    rippedPreview
                } else {
                    Image(decorative: region.extractedImage, scale: 1)
                        .resizable()
                        .scaledToFit()
                }

                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .red)
                }
                .padding(4)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
            )

            Button {
                onToggleEdge()
            } label: {
                Label(
                    region.useRippedEdge ? "Ripped Edge" : "Clean Edge",
                    systemImage: region.useRippedEdge ? "scissors" : "square"
                )
                .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var rippedPreview: some View {
        let imageData = UIImage(cgImage: region.extractedImage).pngData() ?? Data()
        if let ripped = PaperEffectsRenderer.applyRippedEdges(
            to: imageData,
            seed: region.id.hashValue,
            roughness: 0.5
        ) {
            Image(uiImage: ripped)
                .resizable()
                .scaledToFit()
        } else {
            Image(decorative: region.extractedImage, scale: 1)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    ClipConfirmationSheet(viewModel: SmartClippingViewModel())
}
