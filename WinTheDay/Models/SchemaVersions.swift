import Foundation
import SwiftData

// V1: Original schema with Block only
enum SchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Block.self] }

    @Model
    final class Block {
        var startTime: Date
        var durationSeconds: Int
        var objective: String
        var summary: String

        init(startTime: Date, durationSeconds: Int, objective: String = "", summary: String = "") {
            self.startTime = startTime
            self.durationSeconds = durationSeconds
            self.objective = objective
            self.summary = summary
        }
    }
}

// V2: Added NoteEntry with relationship to Block
enum SchemaV2: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Block.self, NoteEntry.self] }

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
    }

    @Model
    final class NoteEntry {
        var text: String
        var typeRaw: String
        var createdAt: Date
        var block: Block?

        init(text: String, typeRaw: String, createdAt: Date = Date(), block: Block? = nil) {
            self.text = text
            self.typeRaw = typeRaw
            self.createdAt = createdAt
            self.block = block
        }
    }
}

enum WinTheDayMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )
}
