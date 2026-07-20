## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Consolidating UI-level Traversals in Alerts Screen
**Learning:** UI screens or build methods often execute multiple independent `.where(...)` operations on lists to render counts or partition child lists for different tabs (e.g., All, Critical, Resolved). This triggers redundant linear O(N) scans and list allocations.
**Action:** Compute all necessary metrics and partitioned lists in a single-pass O(N) loop during build execution and pass the results down to the sub-widgets, reducing complexity and eliminating compiler warnings for unused local variables.
