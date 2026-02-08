import SwiftUI

@main
struct MoodScapeApp: App {
    @StateObject private var store = MoodStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
