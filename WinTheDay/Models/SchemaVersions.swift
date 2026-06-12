import Foundation
import SwiftData

// Schema version tracking for future migrations.
// Current schema: Block + NoteEntry (with completed field)
//
// When a migration is needed:
// 1. Snapshot the current models into a versioned enum (e.g. SchemaV1)
// 2. Make changes to the actual model files
// 3. Create a new versioned enum (e.g. SchemaV2) referencing the updated models
// 4. Add a migration stage and update WinTheDayApp to use the migration plan
