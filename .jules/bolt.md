## 2025-05-15 - Single-pass Aggregation Pattern
**Learning:** The `InsightsEngine` was performing multiple $O(N)$ traversals (filtering, folding) for every insight type check. Consolidating these into a single-pass aggregation using a helper metrics class reduces redundant work and significantly improves efficiency as the data size grows.
**Action:** Always look for multiple `where`, `map`, or `fold` calls on the same collection in service layers and consolidate them into a single loop.

## 2025-05-15 - Drift Database Schema Versioning
**Learning:** Adding tables to a Drift database (like `BehavioralEvents` or `Todos`) requires an explicit increment of the `schemaVersion` in `AppDatabase` and a migration strategy. Failure to do so can cause application crashes on existing installations.
**Action:** Always increment `schemaVersion` when modifying the database schema and ensure all required tables are registered in the `@DriftDatabase` annotation.
