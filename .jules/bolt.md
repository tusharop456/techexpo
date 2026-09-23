## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a some loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Single-pass UI Traversals for List Views
**Learning:** Multiple O(N) `.where` filtering operations in widget build methods can degrade layout performance under large lists. Aggregating counts and partitioning sub-lists in a single-pass loop keeps rendering light.
**Action:** Consolidate multiple redundant list traversals inside UI components into a single-pass loop.
