## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batch Aggregate Database Query Pattern in Drift
**Learning:** Fetching logs and checking data thresholds per-child in `InsightsNotifier` still executes 2N sequential or parallelized queries. Adding `getAllLast7DaysLogs` (using SQL `isIn`) and `getManyHasEnoughData` (using SQL `groupBy` + `selectOnly`) reduces DB queries from 2N to 2 total concurrent batch requests, leaving partitioning to fast in-memory Dart processing.
**Action:** Use SQL `isIn` and `groupBy` batch methods in `AppDatabase` to consolidate multi-entity fetches into constant-time $O(1)$ database round-trips.
