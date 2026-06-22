## 2024-10-24 - [N+1 Query in Insights Provider]
**Learning:** The `InsightsNotifier` was fetching logs and data status individually for every child, leading to an N+1 query pattern that grows with the number of children.
**Action:** Use batch retrieval methods in `AppDatabase` with `isIn` and `groupBy` to fetch all necessary data in 3 queries instead of 3*N.

## 2024-10-24 - [Drift Schema Management]
**Learning:** Modifying the `@DriftDatabase` annotation or adding tables without incrementing `schemaVersion` and providing `MigrationStrategy` causes runtime failures on existing databases.
**Action:** Always increment `schemaVersion` and implement `onUpgrade` in `MigrationStrategy` when adding or modifying tables.
