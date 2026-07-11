## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Batching Database Queries for Insights
**Learning:** Found an N+1 query pattern where the Insights provider fetched logs and checked eligibility per child. This caused 3N+1 queries.
**Action:** Use batch query methods with 'isIn' and 'groupBy' in Drift to fetch all data in 2-3 queries regardless of item count. Group data in Dart memory for efficiency.
