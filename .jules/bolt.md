## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Multiple Linear Traversals in Screen Widgets
**Learning:** Found that screen widgets (like AlertsScreen) often perform multiple separate linear scans (.where) on a single data collection to compute various statistics (like counts, critical alerts, resolved alerts). Consolidating these into a single-pass O(N) loop avoids redundant traversals and extra list allocations during builds.
**Action:** Partition collections and aggregate stats simultaneously in a single loop when multiple list views or counts are rendered together.
