import SwiftUI
import SwiftData

struct StatsView: View {
    @EnvironmentObject private var settings: UserSettings
    @Query private var allBlocks: [Block]

    private let accentColor: Color = .appAccent

    private var todayBlocks: [Block] {
        let calendar = Calendar.current
        return allBlocks.filter { calendar.isDateInToday($0.startTime) }
    }

    private var weekBlocks: [Block] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today),
              let nextMonday = calendar.date(byAdding: .day, value: 7, to: monday) else { return [] }
        return allBlocks.filter { $0.startTime >= monday && $0.startTime < nextMonday }
    }

    private var todayMinutes: Int {
        todayBlocks.reduce(0) { $0 + $1.durationMinutes }
    }

    private var weekMinutes: Int {
        weekBlocks.reduce(0) { $0 + $1.durationMinutes }
    }

    private var todayProgress: Double {
        guard settings.dailyGoalMinutes > 0 else { return 0 }
        return min(Double(todayMinutes) / Double(settings.dailyGoalMinutes), 1.0)
    }

    private var averageMinutesPerBlock: Int {
        guard !weekBlocks.isEmpty else { return 0 }
        return weekMinutes / weekBlocks.count
    }

    var body: some View {
        if allBlocks.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    todaySection
                    weekSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Set a daily goal to track your progress")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.system(size: 14, weight: .semibold))

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.quaternary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * todayProgress, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: todayProgress)
                }
            }
            .frame(height: 6)

            Text("\(todayMinutes) / \(settings.dailyGoalMinutes) min")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Text("\(todayBlocks.count) block\(todayBlocks.count == 1 ? "" : "s") completed")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
    }

    private var currentWeekDays: [(String, Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        // Start from Monday (weekday 2). Adjust so Monday = 0 offset.
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else { return [] }

        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: monday)!
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let minutes = allBlocks
                .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
                .reduce(0) { $0 + $1.durationMinutes }
            return (dayNames[offset], minutes)
        }
    }

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.system(size: 14, weight: .semibold))

            VStack(spacing: 4) {
                ForEach(currentWeekDays, id: \.0) { day, minutes in
                    HStack {
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, alignment: .leading)

                        GeometryReader { geometry in
                            let progress = settings.dailyGoalMinutes > 0
                                ? min(Double(minutes) / Double(settings.dailyGoalMinutes), 1.0)
                                : 0
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.quaternary)
                                    .frame(height: 4)
                                if minutes > 0 {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(accentColor)
                                        .frame(width: max(geometry.size.width * progress, 4), height: 4)
                                }
                            }
                        }
                        .frame(height: 4)

                        Text("\(minutes)/\(settings.dailyGoalMinutes)")
                            .font(.system(size: 11))
                            .foregroundStyle(minutes >= settings.dailyGoalMinutes && settings.dailyGoalMinutes > 0 ? accentColor : Color.secondary)
                            .frame(width: 60, alignment: .trailing)
                    }
                    .frame(height: 20)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Total: \(weekMinutes) min (\(weekBlocks.count) block\(weekBlocks.count == 1 ? "" : "s"))")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

            }
            .padding(.top, 4)
        }
    }
}
