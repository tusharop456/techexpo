## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Single-pass UI Widget Construction in Child Profile
**Learning:** `_buildScreenTimeCard` was iterating over `_screenTimeData` 3 separate times (`.fold` for totals, `.map().toList()` for pie chart sections, `.map().toList()` for legend rows). Consolidating into a single `for` loop avoids 2 extra linear traversals and intermediate list allocations per build.
**Action:** Consolidate multiple list traversals in widget build methods into a single-pass loop when generating charts and legends.
