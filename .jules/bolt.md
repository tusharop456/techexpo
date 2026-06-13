## 2025-05-15 - Single-pass Metric Aggregation
**Learning:** Multiple O(N) traversals (filtering, mapping, folding) over the same data collections can lead to significant CPU overhead in performance-critical paths like an AI insights engine.
**Action:** Use a single-pass loop to gather all necessary metrics (totals, category-specific sums, late-night usage) simultaneously. This reduces complexity and improves responsiveness.
