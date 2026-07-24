## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Batching and In-memory Partitioning of Queries
**Learning:** Even with Future.wait parallelization, executing 3N sequential/concurrent queries for N children results in significant SQLite overhead. Batching database calls into 2 queries (one grouping count query, one IN lookup for log records) and partitioning the results in memory reduces database round-trips from 3N to 2 total.
**Action:** Use the `isIn` operator and `groupBy` in Drift to batch query child-specific properties, and perform single-pass mapping/partitioning in Dart memory.
