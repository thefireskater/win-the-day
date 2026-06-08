import Foundation
import SwiftData

// V1: Original schema with Block only
enum SchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [BlockV1.self] }

    @Model
    final class BlockV1 {
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

// V2: Current schema — references the actual model classes
enum SchemaV2: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Block.self, NoteEntry.self] }
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
