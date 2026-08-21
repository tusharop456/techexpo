## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batch Query Aggregation in Drift
**Learning:** Fetching data per child ID in a loop causes $2N$ database round-trips. Drift supports `isIn` for filtering multiple child IDs in a single query and `groupBy` with `selectOnly` for batch aggregation/counts.
**Action:** Use `isIn` and `groupBy` in Drift database queries to batch multi-entity queries into a single round-trip, then group in Dart memory.
