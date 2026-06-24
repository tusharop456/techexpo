## 2026-01-28 - [Performance vs. Schema Stability]
**Learning:** Bundling performance optimizations with destructive schema changes (like removing orphaned tables) can lead to regressions and out-of-scope breaking changes. Also, batch fetching in Drift should be complemented by parallelizing the calls with Future.wait to minimize total latency.
**Action:** Always verify if a schema change is truly necessary for the optimization. Keep optimizations focused and use Future.wait when making multiple independent batch queries.

## 2026-01-28 - [Single-Pass Aggregation Pattern]
**Learning:** For analytical services like InsightsEngine, consolidating multiple O(N) traversals (filtering, mapping, folding) into a single-pass loop with a helper class significantly reduces CPU overhead on large log datasets.
**Action:** Look for repeated iterations over the same collection in service layers and consolidate them into a single pass.
