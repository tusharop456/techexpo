## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Single Controller Staggered Animations
**Learning:** Wrapping children of a list in separate `AnimationController` widgets and delayed `Future.delayed` timers creates allocation churn and ticker overhead. Driving staggered offsets via a single `AnimationController` with interval fraction calculations eliminates N controllers and avoids frame-by-frame `CurvedAnimation` object allocations.
**Action:** Use a single `AnimationController` and compute progress intervals directly for staggered list animations.
