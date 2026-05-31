import SwiftUI
import SwiftData

private enum Either: Identifiable {
    case block(Block)
    case note(NoteEntry)

    var id: String {
        switch self {
        case .block(let b): return "block-\(b.id)"
        case .note(let n): return "note-\(n.id)"
        }
    }
}

struct BlockLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Block.startTime, order: .reverse) private var allBlocks: [Block]
    @State private var selectedDate: Date = Date()
    @Query(sort: \NoteEntry.createdAt, order: .reverse) private var allNotes: [NoteEntry]
    @State private var selectedBlock: Block?
    @State private var isEditing = false
    @State private var noteText = ""
    @State private var noteType: NoteType = .win

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

    private var standaloneNotes: [NoteEntry] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: selectedDate)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return allNotes.filter { $0.block == nil && $0.createdAt >= dayStart && $0.createdAt < dayEnd }
    }

    private var timelineItems: [(Date, Either)] {
        let blockItems = blocks.map { (date: $0.startTime, item: Either.block($0)) }
        let noteItems = standaloneNotes.map { (date: $0.createdAt, item: Either.note($0)) }
        return (blockItems + noteItems).sorted { $0.0 > $1.0 }
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

                // Quick note input
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ForEach(NoteType.allCases, id: \.self) { type in
                            Button {
                                noteType = type
                            } label: {
                                Image(systemName: type.icon)
                                    .font(.system(size: 10))
                                    .foregroundStyle(noteType == type ? .white : noteColor(for: type))
                                    .frame(width: 22, height: 22)
                                    .background(
                                        Circle()
                                            .fill(noteType == type ? noteColor(for: type) : noteColor(for: type).opacity(0.15))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    TextField("Add a win, thought, or later...", text: $noteText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .onSubmit { addStandaloneNote() }

                    Button {
                        addStandaloneNote()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

                Divider()

                if timelineItems.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("No entries")
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
                            ForEach(timelineItems, id: \.1.id) { _, item in
                                switch item {
                                case .block(let block):
                                    blockRow(block)
                                        .onTapGesture {
                                            selectedBlock = block
                                            isEditing = false
                                        }
                                case .note(let note):
                                    standaloneNoteRow(note)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }

    private func addStandaloneNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let note = NoteEntry(text: trimmed, type: noteType, createdAt: Date())
        modelContext.insert(note)
        try? modelContext.save()
        noteText = ""
    }

    private func standaloneNoteRow(_ note: NoteEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: note.type.icon)
                .font(.system(size: 11))
                .foregroundStyle(noteColor(for: note.type))
                .frame(width: 20, height: 20)
                .background(noteColor(for: note.type).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            VStack(alignment: .leading, spacing: 2) {
                Text(note.text)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
                Text(note.createdAt, format: .dateTime.hour().minute())
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button {
                modelContext.delete(note)
                try? modelContext.save()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private func noteColor(for type: NoteType) -> Color {
        switch type {
        case .win: return .green
        case .thought: return .blue
        case .todo: return .orange
        }
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
