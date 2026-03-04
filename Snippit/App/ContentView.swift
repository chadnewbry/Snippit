import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            MagazineBrowserView()
                .tabItem {
                    Label("Magazine Browser", systemImage: "book")
                }

            CollageCanvasView()
                .tabItem {
                    Label("Collage Canvas", systemImage: "rectangle.on.rectangle")
                }
        }
    }
}

#Preview {
    ContentView()
}
