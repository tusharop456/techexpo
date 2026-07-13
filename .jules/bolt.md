## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Batch Querying vs. Parallel Sequential Queries
**Learning:** Even with parallelization (Future.wait), sequential N+1 queries (like fetching logs per child) incur significant overhead compared to a single batch query (using `isIn` and `groupBy`). Also, fetching a superset (7-day logs) and filtering in-memory for a subset (today's logs) is faster than separate database hits.
**Action:** Prefer batch queries for multiple entities and in-memory partitioning for related data subsets.
