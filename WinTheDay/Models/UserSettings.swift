import Foundation

final class UserSettings: ObservableObject {
    @Published var defaultDurationMinutes: Int {
        didSet { UserDefaults.standard.set(defaultDurationMinutes, forKey: "defaultDurationMinutes") }
    }
    @Published var dailyGoalMinutes: Int {
        didSet { UserDefaults.standard.set(dailyGoalMinutes, forKey: "dailyGoalMinutes") }
    }

    init() {
        let storedDuration = UserDefaults.standard.integer(forKey: "defaultDurationMinutes")
        self.defaultDurationMinutes = storedDuration > 0 ? storedDuration : 25

        let storedGoal = UserDefaults.standard.integer(forKey: "dailyGoalMinutes")
        self.dailyGoalMinutes = storedGoal > 0 ? storedGoal : 240
    }
}
