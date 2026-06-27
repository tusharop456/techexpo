## 2025-05-14 - Optimized insights generation and parallelized database fetches
**Learning:** Found N+1 query pattern in `InsightsNotifier` where database calls for each child were executed sequentially. Also identified O(N) multi-pass traversals in `InsightsEngine` where `where` and `fold` were used repeatedly on the same data.
**Action:** Use `Future.wait` for parallel data fetching when multiple independent queries are needed. Implement a single-pass aggregation pattern to consolidate multiple data traversals into a single O(N) loop.
