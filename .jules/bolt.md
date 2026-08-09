## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batch Sufficiency and In-Memory Superset Partitioning
**Learning:** Combining multiple children's database queries into single batch statements using `isIn` reduces database round-trips from O(N) to O(1). Additionally, since last-7-days logs are a strict superset of today's logs, fetching the 7-day logs and partitioning them in memory completely eliminates the separate "today" query, saving N database round-trips.
**Action:** Check if queried datasets are subsets of each other; if so, fetch the superset once in batch and partition in Dart memory.
