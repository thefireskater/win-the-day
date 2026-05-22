import SwiftUI
import SwiftData

@main
struct WinTheDayApp: App {
    @StateObject private var settings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .frame(width: 400, height: 550)
                .background(.background)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .modelContainer(for: Block.self)
    }
}
