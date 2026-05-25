import SwiftUI
import SwiftData

struct TimerView: View {
    @EnvironmentObject private var settings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: TimerViewModel
    @State private var isEditingDuration = false

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if viewModel.timerState == .stopped {
                BlockSummaryView(viewModel: viewModel)
            } else {
                timerDisplay
                Spacer().frame(height: 32)
                objectiveField
                Spacer().frame(height: 24)
                controlButtons
            }

            Spacer()

            DailyProgressBar(accentColor: accentColor)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
        .onAppear {
            viewModel.modelContext = modelContext
        }
    }

    // MARK: - Timer Display

    @ViewBuilder
    private var timerDisplay: some View {
        if isEditingDuration {
            DurationPickerView(
                selectedMinutes: viewModel.selectedDurationMinutes,
                onSelect: { minutes in
                    viewModel.setDuration(minutes: minutes)
                    isEditingDuration = false
                },
                onCancel: { isEditingDuration = false }
            )
        } else {
            Text(viewModel.displayTime)
                .font(.system(size: 72, weight: .ultraLight, design: .default))
                .monospacedDigit()
                .foregroundStyle(timerColor)
                .opacity(timerOpacity)
                .animation(viewModel.timerState == .paused ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : .default, value: viewModel.timerState)
                .onTapGesture {
                    if viewModel.timerState == .idle {
                        isEditingDuration = true
                    }
                }

            if viewModel.timerState == .idle {
                Text("tap to change")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    private var timerColor: Color {
        switch viewModel.timerState {
        case .idle: return .primary
        case .running: return accentColor
        case .paused: return .primary
        case .stopped: return .primary
        }
    }

    private var timerOpacity: Double {
        viewModel.timerState == .paused ? 0.5 : 1.0
    }

    // MARK: - Objective Field

    private var objectiveField: some View {
        TextField("What are you working on?", text: $viewModel.objective)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(height: 32)
            .padding(.horizontal, 24)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 16) {
            switch viewModel.timerState {
            case .idle:
                Button(action: { viewModel.start() }) {
                    Label("Start", systemImage: "play.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(accentColor)

            case .running:
                Button(action: { viewModel.pause() }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button(action: { viewModel.stop() }) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

            case .paused:
                Button(action: { viewModel.resume() }) {
                    Label("Resume", systemImage: "play.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(accentColor)

                Button(action: { viewModel.stop() }) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

            case .stopped:
                EmptyView()
            }
        }
    }
}
