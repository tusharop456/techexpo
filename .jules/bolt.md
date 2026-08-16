## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-08-16 - Redundant Database Querying for Overlapping Time Windows
**Learning:** `InsightsNotifier.loadInsights()` queried SQLite twice per child: once for last 7 days logs and once for today's logs. Since today's logs are a subset of the 7-day logs, the second query was redundant and added an unnecessary DB roundtrip per child.
**Action:** Fetch superset logs once from DB and partition subsets in Dart memory in a single-pass iteration.
