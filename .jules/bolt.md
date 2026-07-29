## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Redundant List Traversals in Flutter Build Methods
**Learning:** Repeatedly calling `.where` on the same list within Flutter `build` methods or children widgets causes multiple O(N) linear traversals, slowing down UI rendering.
**Action:** Consolidate filtering logic into a single-pass O(N) loop to compute counts and partition lists concurrently, passing the pre-computed subsets down the widget tree.
