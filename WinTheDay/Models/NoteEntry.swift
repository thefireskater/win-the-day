import Foundation
import SwiftData

enum NoteType: String, Codable, CaseIterable {
    case win
    case thought
    case todo

    var label: String {
        switch self {
        case .win: return "Win"
        case .thought: return "Thought"
        case .todo: return "Later"
        }
    }

    var icon: String {
        switch self {
        case .win: return "checkmark.circle.fill"
        case .thought: return "cloud.fill"
        case .todo: return "square"
        }
    }
}

@Model
final class NoteEntry {
    var text: String
    var typeRaw: String
    var createdAt: Date
    var completed: Bool = false
    var sortOrder: Int = 0
    var block: Block?

    init(text: String, type: NoteType, createdAt: Date = Date(), completed: Bool = false, sortOrder: Int = 0, block: Block? = nil) {
        self.text = text
        self.typeRaw = type.rawValue
        self.createdAt = createdAt
        self.completed = completed
        self.sortOrder = sortOrder
        self.block = block
    }

    var type: NoteType {
        get { NoteType(rawValue: typeRaw) ?? .win }
        set { typeRaw = newValue.rawValue }
    }
}
