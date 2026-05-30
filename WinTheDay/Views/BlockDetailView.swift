import SwiftUI
import SwiftData

struct BlockDetailView: View {
    var block: Block
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onDismiss: () -> Void

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12))
                        Text("Back")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Text("Edit")
                        .font(.system(size: 13))
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)
            }

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.startTime, format: .dateTime.month().day().year())
                        .font(.system(size: 14, weight: .semibold))
                    Text(block.startTime, format: .dateTime.hour().minute())
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(block.durationMinutes) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            if !block.objective.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Objective")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(block.objective)
                        .font(.system(size: 14))
                }
            }

            if !block.summary.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Summary")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(block.summary)
                        .font(.system(size: 14))
                }
            }

            // Notes timeline
            if !block.notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Timeline")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(block.notes.sorted(by: { $0.createdAt < $1.createdAt })) { note in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: note.type.icon)
                                    .font(.system(size: 10))
                                    .foregroundStyle(noteColor(for: note.type))
                                    .frame(width: 18, height: 18)
                                    .background(noteColor(for: note.type).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                Text(note.text)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary.opacity(0.3))
                    )
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Block", systemImage: "trash")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }
        .padding(20)
    }

    private func noteColor(for type: NoteType) -> Color {
        switch type {
        case .win: return .green
        case .thought: return .blue
        case .todo: return .orange
        }
    }
}
