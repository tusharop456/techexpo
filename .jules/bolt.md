## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Consolidated AnimationController for Staggered Animations
**Learning:** Instantiating N nested `FadeSlideIn` widgets within a list creates N `AnimationController` instances, N timers, and 2N `CurvedAnimation` listener allocations. Consolidating into a single `AnimationController` using progress-based `Interval` curves eliminates timer overhead and listener allocations.
**Action:** Use a single `AnimationController` with `Interval` progress calculations for staggered list animations.
