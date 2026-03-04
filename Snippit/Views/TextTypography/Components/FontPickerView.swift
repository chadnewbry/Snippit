import SwiftUI

/// Font picker organized by mood categories.
struct FontPickerView: View {
    @Binding var selectedFontName: String
    @State private var selectedMood: FontLibrary.Mood = .handwritten

    var body: some View {
        VStack(spacing: 0) {
            // Mood tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FontLibrary.Mood.allCases) { mood in
                        Button {
                            selectedMood = mood
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: mood.icon)
                                    .font(.title3)
                                Text(mood.rawValue)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedMood == mood ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                        }
                        .foregroundStyle(selectedMood == mood ? .primary : .secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            Divider()

            // Font list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(FontLibrary.fonts(for: selectedMood)) { entry in
                        Button {
                            selectedFontName = entry.name
                        } label: {
                            HStack {
                                Text("Aa")
                                    .font(.custom(entry.name, size: 24))
                                    .frame(width: 50)
                                Text(entry.displayName)
                                    .font(.subheadline)
                                Spacer()
                                if selectedFontName == entry.name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    FontPickerView(selectedFontName: .constant("Georgia"))
        .frame(height: 400)
}
