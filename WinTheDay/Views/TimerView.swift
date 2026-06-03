import SwiftUI
import SwiftData

struct TimerView: View {
    @EnvironmentObject private var settings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: TimerViewModel
    var onBlockComplete: () -> Void = {}
    @State private var isEditingDuration = false
    @State private var pendingCustomMinutes = ""

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if viewModel.timerState == .stopped {
                BlockSummaryView(viewModel: viewModel, onComplete: onBlockComplete)
            } else {
                timerDisplay
                Spacer().frame(height: 16)
                objectiveField
                Spacer().frame(height: 12)
                controlButtons

                if viewModel.timerState == .running || viewModel.timerState == .paused {
                    Spacer().frame(height: 16)
                    noteCaptureSection
                }
            }

            Spacer()

            DailyProgressBar(accentColor: accentColor)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .onChange(of: viewModel.timerState) {
            if viewModel.timerState != .idle {
                isEditingDuration = false
            }
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
                onCancel: { isEditingDuration = false },
                customText: $pendingCustomMinutes
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
        TextField("What are you working on?", text: $viewModel.objective, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(1...4)
            .padding(.horizontal, 24)
    }

    // MARK: - Note Capture

    private var noteCaptureSection: some View {
        VStack(spacing: 8) {
            // Type pills
            HStack(spacing: 6) {
                ForEach(NoteType.allCases, id: \.self) { type in
                    Button {
                        viewModel.selectedNoteType = type
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: type.icon)
                                .font(.system(size: 10))
                            Text(type.label)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedNoteType == type ? accentColor : Color.clear)
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedNoteType == type ? accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundStyle(viewModel.selectedNoteType == type ? .white : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Text field + add button
            HStack(spacing: 6) {
                TextField("What just happened?", text: $viewModel.noteText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .onSubmit {
                        viewModel.addNote()
                    }

                Button {
                    viewModel.addNote()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }

            // Entries list
            if !viewModel.sessionNotes.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.sessionNotes.reversed().enumerated()), id: \.offset) { _, note in
                            noteRow(note)
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
        }
    }

    private func noteRow(_ note: NoteEntry) -> some View {
        VStack(spacing: 0) {
        Divider()
        HStack(alignment: .top, spacing: 8) {
            Button {
                let allTypes = NoteType.allCases
                if let index = allTypes.firstIndex(of: note.type) {
                    note.type = allTypes[(index + 1) % allTypes.count]
                }
            } label: {
                Image(systemName: note.type.icon)
                    .font(.system(size: 11))
                    .foregroundStyle(noteColor(for: note.type))
                    .frame(width: 18, height: 18)
                    .background(noteColor(for: note.type).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)

            Text(note.text)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .lineLimit(2)
            Spacer()

            Button {
                viewModel.sessionNotes.removeAll { $0 === note }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
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

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 16) {
            switch viewModel.timerState {
            case .idle:
                Button(action: {
                    if isEditingDuration, let value = Int(pendingCustomMinutes), value > 0, value <= 120 {
                        viewModel.setDuration(minutes: value)
                    }
                    viewModel.start()
                }) {
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
