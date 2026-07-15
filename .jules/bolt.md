## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - From 3N+1 to Constant 3 Queries for Insights
**Learning:** Even with parallelization, N+1 patterns (like fetching logs per child) generate excessive DB round-trips. Consolidating into batch queries (using `isIn` and `groupBy`) reduces overhead to a constant cost. Additionally, fetching a superset (7-day logs) and partitioning in memory (for "today" logs) eliminates redundant queries.
**Action:** Implement batch query methods in the database layer and use in-memory partitioning for related data subsets.
