## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batch Database Queries and In-Memory Partitioning
**Learning:** Sequential per-child query fetching in providers (such as checking data threshold and retrieving logs) results in a 3N query amplification pattern. Utilizing Drift's groupBy, selectOnly, and isIn operations allowed consolidating these queries into exactly 2 total concurrent batch queries across all children. Today's logs are a subset of the last 7 days' logs and can be partitioned in memory in Dart instead of performing a separate redundant database query.
**Action:** Implement batch query methods inside the database layer (groupBy / isIn) and partition nested subsets of data in Dart memory to eliminate duplicate database round-trips.
