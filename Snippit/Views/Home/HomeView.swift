import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "house")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Home")
                    .font(.title2)
            }
            .navigationTitle("Home")
        }
        .accessibilityIdentifier("homeTab")
    }
}

#Preview {
    HomeView()
}
