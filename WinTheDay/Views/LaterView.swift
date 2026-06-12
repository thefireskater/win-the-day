import SwiftUI
import SwiftData

struct LaterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoteEntry.createdAt, order: .reverse) private var allNotes: [NoteEntry]
    @State private var selectedDate: Date = Date()
    @State private var orderedItems: [NoteEntry] = []

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

    private func laterNotesForDate(_ date: Date) -> [NoteEntry] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return allNotes
            .filter { $0.type == .todo && $0.createdAt >= dayStart && $0.createdAt < dayEnd }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private func refreshItems() {
        orderedItems = laterNotesForDate(selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Day picker
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.1) { label, date in
                    let calendar = Calendar.current
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let dayNum = calendar.component(.day, from: date)
                    Button {
                        selectedDate = date
                        refreshItems()
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

            if orderedItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Text("No items")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(orderedItems) { note in
                        laterRow(note)
                            .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                            .listRowSeparator(.hidden)
                    }
                    .onMove { from, to in
                        orderedItems.move(fromOffsets: from, toOffset: to)
                        for (index, note) in orderedItems.enumerated() {
                            note.sortOrder = index
                        }
                        try? modelContext.save()
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear { refreshItems() }
        .onChange(of: allNotes.count) { refreshItems() }
    }

    private func laterRow(_ note: NoteEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                note.completed.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: note.completed ? "checkmark.square.fill" : "square")
                    .font(.system(size: 16))
                    .foregroundStyle(note.completed ? accentColor : .secondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(note.text)
                    .font(.system(size: 13))
                    .foregroundStyle(note.completed ? .secondary : .primary)
                    .strikethrough(note.completed)
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
