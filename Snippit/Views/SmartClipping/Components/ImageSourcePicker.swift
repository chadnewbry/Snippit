import PhotosUI
import SwiftUI

/// Landing state: lets user pick an image source (photo library or camera).
struct ImageSourcePicker: View {
    @Binding var showCamera: Bool
    @Binding var selectedPhotos: [PhotosPickerItem]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "scissors")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Choose a source to start clipping")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ImageSourcePicker(showCamera: .constant(false), selectedPhotos: .constant([]))
        .background(Color.black)
}
