## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Consolidating Multiple UI O(N) scans on Alerts List
**Learning:** The AlertsScreen widget was performing 5 separate O(N) list traversals (via .where operations) inside the build method and child builder helpers to count unread alerts, count critical alerts, and partition the tabs. Consolidating these into a single-pass loop improves performance during UI rendering and avoids redundant list filtering.
**Action:** Consolidate multiple linear scans on collections inside build methods or UI rendering pathways into a single-pass collection traversal.
