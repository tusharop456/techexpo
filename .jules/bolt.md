## 2026-01-29 - Single-pass aggregation optimization
**Learning:** In service layers that perform multiple data aggregations (like the InsightsEngine), standard functional patterns like multiple `.where().fold()` chains result in multiple O(N) passes. While readable, this becomes a bottleneck as historical log data grows.
**Action:** Use a single-pass loop with a helper metrics class to collect all necessary data points in one traversal. This maintains readability while ensuring O(N) complexity for any number of derived metrics.
