## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Consolidating UI List Traversals in Alerts Screen
**Learning:** Performing multiple independent `.where` filters on a Riverpod-watched list in the UI build tree causes 5 separate linear O(N) traversals per widget rebuild, which impacts UI responsiveness and frame rates.
**Action:** Consolidate multiple list-filtering traversals into a single-pass O(N) loop during `build()` to partition the list and compute state counts concurrently, then pass these pre-computed results to downstream sub-widgets.
