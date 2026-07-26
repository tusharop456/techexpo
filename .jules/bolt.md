## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Redundant List-filtering traversals in AlertsScreen
**Learning:** The alerts screen UI was running multiple separate linear `.where` filters over the mapped alert list in build methods/widgets to count categories and construct lists, resulting in O(N) overhead repeatedly.
**Action:** Consolidate list filtering traversals into a single-pass O(N) loop to partition and compute counts simultaneously.
