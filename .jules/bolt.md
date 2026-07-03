## 2026-01-28 - Single-Pass Aggregation & Parallel Data Fetching
**Learning:** Redundant O(N) traversals on large activity logs and sequential database awaits for multiple children significantly slowed down insight generation.
**Action:** Consolidate filtering/mapping into a single-pass loop and use Future.wait to parallelize independent database queries in providers.
