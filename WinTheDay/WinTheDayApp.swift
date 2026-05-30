import SwiftUI
import SwiftData

@main
struct WinTheDayApp: App {
    @StateObject private var settings = UserSettings()
    @StateObject private var timerViewModel = TimerViewModel()
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Block.self, NoteEntry.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    private var menuBarTitle: String {
        switch timerViewModel.timerState {
        case .running, .paused:
            return timerViewModel.displayTime
        case .idle, .stopped:
            return ""
        }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView(timerViewModel: timerViewModel)
                .environmentObject(settings)
                .modelContainer(modelContainer)
                .frame(width: 400, height: 550)
                .background(.background)
        } label: {
            if menuBarTitle.isEmpty {
                Label("Win the Day", systemImage: "trophy.fill")
            } else {
                Text("⏱ \(menuBarTitle)")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
