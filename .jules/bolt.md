## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Redundant Widget-Level List Traversals
**Learning:** Found multiple separate .where() linear traversals inside build and build helper methods in AlertsScreen for calculating counts and filtering the main alerts list, resulting in 5x O(N) overhead.
**Action:** Consolidate multiple list filtering linear traversals in build methods into a single-pass O(N) loop to compute counts and partition lists concurrently.
