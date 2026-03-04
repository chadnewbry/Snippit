import PhotosUI
import SwiftUI

/// Primary Smart Clipping & Selection view — entry point for all clipping workflows.
struct SmartClippingView: View {
    @State private var viewModel = SmartClippingViewModel()
    @State private var showCamera = false
    @State private var selectedPhotos: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if viewModel.sourceImage != nil {
                    ClippingCanvasView(viewModel: viewModel)
                } else {
                    ImageSourcePicker(
                        showCamera: $showCamera,
                        selectedPhotos: $selectedPhotos
                    )
                }
            }
            .navigationTitle("Smart Clip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.sourceImage != nil {
                        Button("Back") {
                            viewModel.reset()
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.sourceImage != nil && !viewModel.clippedRegions.isEmpty {
                        Button("Clip It") {
                            viewModel.showClipConfirmation = true
                        }
                        .bold()
                    }
                }
            }
            .onChange(of: selectedPhotos) { _, items in
                Task {
                    await viewModel.loadPhotos(items)
                    selectedPhotos = []
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView { image in
                    viewModel.setSourceImage(image)
                }
            }
            .sheet(isPresented: $viewModel.showClipConfirmation) {
                ClipConfirmationSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
        }
        .accessibilityIdentifier("smartClippingTab")
    }
}

#Preview {
    SmartClippingView()
}
