## 2026-06-29 - [Consolidated Single-Pass Aggregation in InsightsEngine]
**Learning:** Multiple O(N) traversals (filter/map/fold) on the same collection for different metrics are inefficient. Consolidating into a single pass significantly reduces CPU cycles, especially as data grows.
**Action:** Use a single loop with a temporary metrics object to gather all necessary data points in one traversal.
