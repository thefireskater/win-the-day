import SwiftUI

struct BlockSummaryView: View {
    @ObservedObject var viewModel: TimerViewModel

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.showDone {
                Text("Done")
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(accentColor)
            } else {
                Text("Great block! What did you accomplish?")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                TextEditor(text: $viewModel.summaryText)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )

                HStack {
                    Button("Skip") {
                        viewModel.skipSummary()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button("Save & Continue") {
                        viewModel.saveSummary()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(accentColor)
                    .fontWeight(.medium)
                }

                Text("Block saved: \(viewModel.lastBlockDurationMinutes) min")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
    }
}
