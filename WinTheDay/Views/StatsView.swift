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
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return [] }
        return allBlocks.filter { $0.startTime >= weekAgo }
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

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.system(size: 14, weight: .semibold))

            VStack(alignment: .leading, spacing: 4) {
                Text("Total: \(weekMinutes) min (\(weekBlocks.count) block\(weekBlocks.count == 1 ? "" : "s"))")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                if !weekBlocks.isEmpty {
                    Text("Average: \(averageMinutesPerBlock) min/block")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
