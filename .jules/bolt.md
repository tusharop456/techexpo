## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-12 - Consolidating UI List Filtering Traversals
**Learning:** Build methods or helper widgets in Flutter screens (like `AlertsScreen`) often perform multiple `.where()` calls over a fetched list to count, partition, or group elements for separate tabs/views. This results in redundant, consecutive O(N) linear traversals. Doing a single-pass loop over the list to count and partition elements simultaneously improves the screen's rendering performance dramatically.
**Action:** Combine separate list filters/counts into a single-pass traversal loop inside the `build` method or main controller, and pass pre-partitioned list subsets to tab views or child widgets.
