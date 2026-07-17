## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batching Database Queries for Family Analytics
**Learning:** Even with parallelized `Future.wait` fetches, querying SQLite/Drift multiple times per child (e.g. `hasEnoughData`, `getLast7DaysLogs`, `getTodayLogs`) creates high connection overhead and redundant queries as "Today" logs are a strict subset of "7 Days" logs. Consolidating this into parallelized batch database queries (`getManyHasEnoughData` and `getAllLast7DaysLogs`) and partitioning/filtering in memory completely eliminates the $3N$ scaling overhead.
**Action:** Use SQL grouped aggregations (`groupBy`) and `isIn` to batch fetch multi-child metrics, and partition/filter data sets in memory to minimize database roundtrips.
