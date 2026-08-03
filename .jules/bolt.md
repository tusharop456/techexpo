## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batch Query Aggregation for Insights
**Learning:** Parallelizing DB fetches with Future.wait for N individual children still performs 3N database queries (N+1 queries pattern), incurring high query overhead. Instead, fetching all children's data in 2 batch database queries concurrently (using Drift 'isIn' and in-memory Dart filtering) completely eliminates the N+1 query overhead.
**Action:** Consolidate sequential or parallel per-child queries into single batch select-in queries, then partition and map the results in Dart memory.
