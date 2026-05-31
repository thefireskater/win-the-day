import Foundation
import SwiftData
import AppKit

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case stopped
}

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var timerState: TimerState = .idle
    @Published var remainingSeconds: Int
    @Published var selectedDurationMinutes: Int
    @Published var objective: String = ""
    @Published var summaryText: String = ""
    @Published var noteText: String = ""
    @Published var selectedNoteType: NoteType = .win
    @Published var sessionNotes: [NoteEntry] = []

    private var timer: Timer?
    private var completionSound: NSSound?
    private var blockStartTime: Date?
    private var runSegmentStart: Date?
    private var elapsedSecondsAtPause: Int = 0
    private var currentBlock: Block?
    private var totalDurationSeconds: Int { selectedDurationMinutes * 60 }

    var modelContext: ModelContext?

    init(defaultMinutes: Int = 25) {
        self.selectedDurationMinutes = defaultMinutes
        self.remainingSeconds = defaultMinutes * 60
    }

    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var wallClockElapsed: Int {
        guard let segmentStart = runSegmentStart else { return elapsedSecondsAtPause }
        return elapsedSecondsAtPause + Int(Date().timeIntervalSince(segmentStart))
    }

    var lastBlockDurationMinutes: Int {
        currentBlock?.durationMinutes ?? 0
    }

    func start() {
        guard timerState == .idle else { return }
        blockStartTime = Date()
        runSegmentStart = Date()
        elapsedSecondsAtPause = 0
        timerState = .running
        startTimer()
    }

    func pause() {
        guard timerState == .running else { return }
        elapsedSecondsAtPause = wallClockElapsed
        runSegmentStart = nil
        stopTimer()
        timerState = .paused
    }

    func resume() {
        guard timerState == .paused else { return }
        runSegmentStart = Date()
        timerState = .running
        startTimer()
    }

    func stop() {
        stopTimer()
        let elapsed = wallClockElapsed
        runSegmentStart = nil
        if let ctx = modelContext {
            saveBlock(elapsedSeconds: elapsed, modelContext: ctx)
        }
        handleCompletion()
    }

    func saveSummary() {
        stopSound()
        if let block = currentBlock, let ctx = modelContext {
            block.summary = summaryText
            try? ctx.save()
        }
        currentBlock = nil
        resetToIdle()
    }

    func skipSummary() {
        stopSound()
        currentBlock = nil
        resetToIdle()
    }

    func addNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let note = NoteEntry(text: trimmed, type: selectedNoteType)
        sessionNotes.append(note)
        noteText = ""
    }

    func setDuration(minutes: Int) {
        guard timerState == .idle else { return }
        selectedDurationMinutes = minutes
        remainingSeconds = minutes * 60
    }

    func resetToIdle() {
        summaryText = ""
        objective = ""
        noteText = ""
        sessionNotes = []
        remainingSeconds = selectedDurationMinutes * 60
        timerState = .idle
    }

    // MARK: - Private

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard timerState == .running else { return }
        let elapsed = wallClockElapsed
        remainingSeconds = max(totalDurationSeconds - elapsed, 0)
        if remainingSeconds <= 0 {
            stopTimer()
            runSegmentStart = nil
            if let ctx = modelContext {
                saveBlock(elapsedSeconds: totalDurationSeconds, modelContext: ctx)
            }
            handleCompletion()
        }
    }

    private func handleCompletion() {
        timerState = .stopped
        playCompletionSound()
    }

    private func saveBlock(elapsedSeconds: Int, modelContext: ModelContext) {
        guard elapsedSeconds > 0 else { return }
        let block = Block(
            startTime: blockStartTime ?? Date(),
            durationSeconds: elapsedSeconds,
            objective: objective
        )
        modelContext.insert(block)
        for note in sessionNotes {
            note.block = block
            modelContext.insert(note)
        }
        try? modelContext.save()
        currentBlock = block
    }

    var isSoundPlaying: Bool {
        completionSound?.isPlaying ?? false
    }

    func stopSound() {
        completionSound?.stop()
        completionSound = nil
    }

    private func playCompletionSound() {
        let journeyPath = "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/Ringtones/Journey-EncoreInfinitum.m4r"
        let sound = NSSound(contentsOf: URL(fileURLWithPath: journeyPath), byReference: true) ?? NSSound(named: "Glass")
        completionSound = sound
        sound?.play()
    }
}
