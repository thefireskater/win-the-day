import SwiftUI
import SwiftData

struct BlockEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var block: Block
    var onDelete: () -> Void
    var onDismiss: () -> Void
    @State private var editingNoteId: PersistentIdentifier?

    var body: some View {
        ScrollView {
        VStack(spacing: 16) {
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
                    .foregroundStyle(Color.appAccent)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Edit Block")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Objective")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("Objective", text: $block.objective)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.quaternary.opacity(0.5))
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Summary")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextEditor(text: $block.summary)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(4)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.quaternary.opacity(0.5))
                    )
            }

            HStack {
                Text(block.startTime, format: .dateTime.month().day().hour().minute())
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text("\(block.durationMinutes) min")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            // Editable timeline
            if !block.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timeline")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                    ForEach(block.notes.sorted(by: { $0.createdAt < $1.createdAt })) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: note.type.icon)
                                .font(.system(size: 10))
                                .foregroundStyle(noteColor(for: note.type))
                                .frame(width: 18, height: 18)
                                .background(noteColor(for: note.type).opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            if editingNoteId == note.persistentModelID {
                                TextField("Note", text: Binding(
                                    get: { note.text },
                                    set: { note.text = $0 }
                                ))
                                .textFieldStyle(.plain)
                                .font(.system(size: 12))
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.quaternary.opacity(0.5))
                                )
                                .onSubmit {
                                    editingNoteId = nil
                                    try? modelContext.save()
                                }
                            } else {
                                Text(note.text)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.primary)
                                    .onTapGesture {
                                        editingNoteId = note.persistentModelID
                                    }
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
                        .padding(.vertical, 2)
                    }
                }
            }

            HStack {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)

                Spacer()

                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.appAccent)
                .fontWeight(.medium)
            }
        }
        .padding(20)
        }
    }

    private func noteColor(for type: NoteType) -> Color {
        switch type {
        case .win: return .green
        case .thought: return .blue
        case .todo: return .orange
        }
    }
}
