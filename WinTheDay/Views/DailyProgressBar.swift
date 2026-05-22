import SwiftUI
import SwiftData

struct DailyProgressBar: View {
    @EnvironmentObject private var settings: UserSettings
    @Query private var todayBlocks: [Block]
    let accentColor: Color

    init(accentColor: Color) {
        self.accentColor = accentColor
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        _todayBlocks = Query(
            filter: #Predicate<Block> { block in
                block.startTime >= startOfDay && block.startTime < endOfDay
            }
        )
    }

    private var totalMinutesToday: Int {
        todayBlocks.reduce(0) { $0 + $1.durationMinutes }
    }

    private var progress: Double {
        guard settings.dailyGoalMinutes > 0 else { return 0 }
        return min(Double(totalMinutesToday) / Double(settings.dailyGoalMinutes), 1.0)
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.quaternary)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * progress, height: 3)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 3)

            Text("\(totalMinutesToday) of \(settings.dailyGoalMinutes) min")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}
