import Foundation
import SwiftData

@Model
final class Block {
    var startTime: Date
    var durationSeconds: Int
    var objective: String
    var summary: String
    @Relationship(deleteRule: .cascade, inverse: \NoteEntry.block)
    var notes: [NoteEntry] = []

    init(startTime: Date, durationSeconds: Int, objective: String = "", summary: String = "") {
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.objective = objective
        self.summary = summary
    }

    var durationMinutes: Int {
        durationSeconds / 60
    }
}
