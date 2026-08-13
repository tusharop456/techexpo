## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Overlapping Date-range Database Queries
**Learning:** Found that the InsightsNotifier was fetching both the last 7 days of logs and today's logs from the database. Today's logs are a subset of the last 7 days of logs, resulting in redundant database queries and round-trips.
**Action:** Query the largest date-range needed and filter smaller sub-intervals in memory using Dart to save database round-trips.
