## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Batching is superior to Parallelizing N queries
**Learning:** While `Future.wait` parallelizes queries, it still results in $3N+1$ database round-trips. Using SQL `isIn` and `groupBy` allows fetching all data in just 3 total queries regardless of the number of children ($N$).
**Action:** Implement batch query methods in the database layer (e.g., `getManyHasEnoughData`, `getAllLast7DaysLogs`) and process results in-memory.
