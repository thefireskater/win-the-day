import SwiftUI

struct BlockSummaryView: View {
    @ObservedObject var viewModel: TimerViewModel

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 20) {
            Text("Done!")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(accentColor)

            Text("\(viewModel.lastBlockDurationMinutes) min block saved")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

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
                .overlay(alignment: .topLeading) {
                    if viewModel.summaryText.isEmpty {
                        Text("What did you accomplish?")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 13)
                            .padding(.top, 12)
                            .allowsHitTesting(false)
                    }
                }

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
        }
        .padding(.horizontal, 24)
    }
}
