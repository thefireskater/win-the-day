import SwiftUI
import SwiftData

struct BlockLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Block.startTime, order: .reverse) private var allBlocks: [Block]
    @State private var selectedDate: Date = Date()
    @State private var selectedBlock: Block?
    @State private var isEditing = false

    var onSwitchToTimer: () -> Void

    private let accentColor: Color = .appAccent

    private var weekDays: [(String, Date)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: today) else { return [] }
        let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
        return (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: offset, to: monday)!
            return (dayLabels[offset], calendar.startOfDay(for: day))
        }
    }

    private var blocks: [Block] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return allBlocks.filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
    }

    private var selectedDayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: selectedDate)
        }
    }

    var body: some View {
        if let block = selectedBlock, isEditing {
            BlockEditView(block: block, onDelete: {
                modelContext.delete(block)
                try? modelContext.save()
                selectedBlock = nil
                isEditing = false
            }, onDismiss: {
                try? modelContext.save()
                isEditing = false
            })
        } else if let block = selectedBlock {
            BlockDetailView(block: block, onEdit: {
                isEditing = true
            }, onDelete: {
                modelContext.delete(block)
                try? modelContext.save()
                selectedBlock = nil
            }, onDismiss: {
                selectedBlock = nil
            })
        } else {
            VStack(spacing: 0) {
                // Day picker
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.1) { label, date in
                        let calendar = Calendar.current
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let dayNum = calendar.component(.day, from: date)
                        Button {
                            selectedDate = date
                        } label: {
                            VStack(spacing: 2) {
                                Text(label)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text("\(dayNum)")
                                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                    .foregroundStyle(isSelected ? .white : .primary)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(isSelected ? accentColor : Color.clear)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()

                if blocks.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("No blocks")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        if Calendar.current.isDateInToday(selectedDate) {
                            Button("Go to Timer") {
                                onSwitchToTimer()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(accentColor)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            sectionHeader(selectedDayLabel)
                            ForEach(blocks) { block in
                                blockRow(block)
                                    .onTapGesture {
                                        selectedBlock = block
                                        isEditing = false
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private func blockRow(_ block: Block) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(block.startTime, format: .dateTime.hour().minute())
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(block.durationMinutes) min")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            if !block.summary.isEmpty {
                Text(block.summary)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }

            if !block.objective.isEmpty {
                Text("Objective: \(block.objective)")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }

            Divider()
                .padding(.top, 8)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
