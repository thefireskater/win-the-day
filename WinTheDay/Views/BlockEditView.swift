import SwiftUI
import SwiftData

struct BlockEditView: View {
    @Bindable var block: Block
    var onDelete: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Edit Block")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
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

            Spacer()

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
