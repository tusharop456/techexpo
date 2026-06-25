## 2025-05-15 - Batch Database Fetching in InsightsNotifier
**Learning:** The previous implementation of `InsightsNotifier.loadInsights` had an N+1 query problem, fetching data separately for each child. This would scale poorly with more children.
**Action:** Use Drift's `isIn` operator and `groupBy` to fetch data for all children in a single query. Parallelize independent batch fetches using `Future.wait`.
