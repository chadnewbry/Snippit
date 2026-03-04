import SwiftUI

struct MagazineBrowserView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "book")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Magazine Browser")
                    .font(.title2)
            }
            .navigationTitle("Magazine Browser")
        }
        .accessibilityIdentifier("magazineBrowserTab")
    }
}

#Preview {
    MagazineBrowserView()
}
