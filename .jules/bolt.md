## 2026-01-28 - Avoid breaking schema changes during optimization
**Learning:** Destructive database schema changes (like removing existing tables or changing return types in providers) must be avoided even during performance optimizations, as they cause major regressions and maintenance debt.
**Action:** Always verify that existing entities (e.g., 'Todos') are preserved and that Drift query methods for metrics use server-side aggregation (SQL count/avg) instead of fetching all rows to memory.

## 2026-01-28 - N+1 Query Pattern in Insights Generation
**Learning:** Sequential awaits for multiple data points per entity in a loop create a significant performance bottleneck (N+1 database round-trips).
**Action:** Use 'Future.wait' to parallelize database fetches within providers and notifiers to reduce overall latency.

## 2026-01-28 - O(N) Traversal Optimization
**Learning:** Multiple O(N) passes (where, fold, filter) on the same dataset can be consolidated into a single pass for significant speedups.
**Action:** Implement single-pass aggregation using helper classes to minimize redundant iterations over log data.
