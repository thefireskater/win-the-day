import SwiftUI

struct BlockSummaryView: View {
    @ObservedObject var viewModel: TimerViewModel
    var onComplete: () -> Void
    @FocusState private var isSummaryFocused: Bool

    private let accentColor: Color = .appAccent

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Done!")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(accentColor)

                Text("\(viewModel.lastBlockDurationMinutes) min block saved")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                if !viewModel.sessionNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(viewModel.sessionNotes.enumerated()), id: \.offset) { _, note in
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

                TextEditor(text: $viewModel.summaryText)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if viewModel.summaryText.isEmpty {
                            Text("How did it go?")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                                .padding(.leading, 13)
                                .padding(.top, 12)
                                .allowsHitTesting(false)
                        }
                    }
                    .focused($isSummaryFocused)
                    .onChange(of: isSummaryFocused) {
                        if isSummaryFocused { viewModel.stopSound() }
                    }
                    .onChange(of: viewModel.summaryText) {
                        viewModel.stopSound()
                    }

                HStack {
                    Button("Skip") {
                        viewModel.skipSummary()
                        onComplete()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button("Save & Continue") {
                        viewModel.saveSummary()
                        onComplete()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(accentColor)
                    .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
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
