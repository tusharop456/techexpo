## 2025-05-14 - Single-Pass Aggregation in InsightsEngine
**Learning:** The `InsightsEngine` was performing multiple O(N) traversals on activity logs to calculate different metrics. Consolidating these into a single loop using a helper class significantly improves efficiency, especially as the number of logs grows.
**Action:** Always look for redundant `where` and `fold` operations on the same dataset and consolidate them into a single-pass aggregation pattern.
