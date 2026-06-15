## 2026-06-15 - [Single-Pass Aggregation & SQL Aggregates]
**Learning:** Multiple O(N) traversals on large datasets (like activity logs) can be consolidated into a single pass. Similarly, performing calculations (count, average) in Dart by fetching all rows is inefficient compared to using SQL aggregate functions.
**Action:** Always check if multiple 'where' or 'fold' operations on the same list can be combined. Use 'selectOnly' with expressions like 'count()' or 'avg()' in Drift for metrics.
