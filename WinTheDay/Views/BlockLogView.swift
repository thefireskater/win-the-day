import SwiftUI
import SwiftData

struct BlockLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Block.startTime, order: .reverse) private var blocks: [Block]
    @State private var blockToDelete: Block?
    @State private var showDeleteConfirmation = false

    var onSwitchToTimer: () -> Void

    private func sectionKey(for block: Block) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(block.startTime) {
            return "Today"
        } else if calendar.isDateInYesterday(block.startTime) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: block.startTime)
        }
    }

    private var groupedBlocks: [(String, [Block])] {
        let grouped = Dictionary(grouping: blocks) { sectionKey(for: $0) }
        var seen = Set<String>()
        let uniqueOrder = blocks.compactMap { block -> String? in
            let key = sectionKey(for: block)
            return seen.insert(key).inserted ? key : nil
        }
        return uniqueOrder.compactMap { key in
            guard let values = grouped[key] else { return nil }
            return (key, values)
        }
    }

    var body: some View {
        if blocks.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(groupedBlocks, id: \.0) { group in
                        sectionHeader(group.0)
                        ForEach(group.1) { block in
                            blockRow(block)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        blockToDelete = block
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete Block", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .alert("Delete Block?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { blockToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let block = blockToDelete {
                        modelContext.delete(block)
                        try? modelContext.save()
                    }
                    blockToDelete = nil
                }
            } message: {
                Text("This block will be permanently deleted.")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Start your first block")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            Button("Go to Timer") {
                onSwitchToTimer()
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.appAccent)
            Spacer()
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
    }
}
