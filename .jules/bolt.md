## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Single-pass UI List Partitioning in Alerts Screen
**Learning:** Found that the AlertsScreen was performing five separate linear O(N) traversals (using `.where` filters) on the list of alerts during build time to calculate badges and partition lists. Consolidating this into a single-pass O(N) loop dramatically improves build rendering performance and avoids redundant filter iterations.
**Action:** In widgets displaying filtered tab views or counts from a shared dataset, perform a single-pass iteration in the build method to partition list subsets and aggregate counts.
