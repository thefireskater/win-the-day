import Foundation
import SwiftData
import AppKit
import Combine

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
    @Published var showDone: Bool = false

    private var timer: Timer?
    private var blockStartTime: Date?
    private var elapsedSecondsAtPause: Int = 0
    private var totalDurationSeconds: Int { selectedDurationMinutes * 60 }

    init(defaultMinutes: Int = 25) {
        self.selectedDurationMinutes = defaultMinutes
        self.remainingSeconds = defaultMinutes * 60
    }

    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var elapsedSeconds: Int {
        totalDurationSeconds - remainingSeconds
    }

    func start() {
        guard timerState == .idle else { return }
        blockStartTime = Date()
        elapsedSecondsAtPause = 0
        timerState = .running
        startTimer()
    }

    func pause() {
        guard timerState == .running else { return }
        elapsedSecondsAtPause = elapsedSeconds
        stopTimer()
        timerState = .paused
    }

    func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        startTimer()
    }

    func stop(modelContext: ModelContext) {
        stopTimer()
        let elapsed = elapsedSeconds
        saveBlock(elapsedSeconds: elapsed, modelContext: modelContext)
        timerState = .stopped
        playCompletionSound()
        showDone = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showDone = false
        }
    }

    func saveSummary(modelContext: ModelContext) {
        // Update the most recent block with the summary
        let descriptor = FetchDescriptor<Block>(sortBy: [SortDescriptor(\.startTime, order: .reverse)])
        if let blocks = try? modelContext.fetch(descriptor), let latest = blocks.first {
            latest.summary = summaryText
            try? modelContext.save()
        }
        resetToIdle()
    }

    func skipSummary() {
        resetToIdle()
    }

    func setDuration(minutes: Int) {
        guard timerState == .idle else { return }
        selectedDurationMinutes = minutes
        remainingSeconds = minutes * 60
    }

    func resetToIdle() {
        summaryText = ""
        objective = ""
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
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        if remainingSeconds <= 0 {
            // Timer completed naturally
            stopTimer()
            let elapsed = totalDurationSeconds
            timerState = .stopped
            playCompletionSound()
            showDone = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.showDone = false
            }
            // Block will be saved by the view when it detects the state change
        }
    }

    func saveBlockOnCompletion(modelContext: ModelContext) {
        saveBlock(elapsedSeconds: totalDurationSeconds, modelContext: modelContext)
    }

    private func saveBlock(elapsedSeconds: Int, modelContext: ModelContext) {
        guard elapsedSeconds > 0 else { return }
        let block = Block(
            startTime: blockStartTime ?? Date(),
            durationSeconds: elapsedSeconds,
            objective: objective
        )
        modelContext.insert(block)
        try? modelContext.save()
    }

    private func playCompletionSound() {
        NSSound(named: "Glass")?.play()
    }
}
