import SwiftUI
import SwiftData

@main
struct WinTheDayApp: App {
    @StateObject private var settings = UserSettings()
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Block.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        MenuBarExtra("Win the Day", systemImage: "trophy.fill") {
            ContentView()
                .environmentObject(settings)
                .modelContainer(modelContainer)
                .frame(width: 400, height: 550)
                .background(.background)
        }
        .menuBarExtraStyle(.window)
    }
}
