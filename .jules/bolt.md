## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Consolidating O(N) Traversals in UI Build Methods
**Learning:** Build methods that perform multiple separate linear scans (.where filter, count calculations) on large lists can cause high memory allocations (creating intermediate LazyIterables/Lists) and CPU overhead on each widget rebuild.
**Action:** Consolidate multiple list filter, maps, and length operations into a single-pass loop inside widget `build` methods to concurrently partition lists and compute metric counts in $O(N)$ complexity.
