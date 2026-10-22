## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - Single AnimationController for Staggered Animations
**Learning:** Animating lists of items with individual `FadeSlideIn` instances instantiated $N$ distinct `AnimationControllers` and $N$ separate `Future.delayed` timer callbacks, causing fragmented tick notifications and excessive memory allocations.
**Action:** Consolidate staggered list item animations into a single `AnimationController` with per-item progress derived statelessly via `Interval(...).transform(_controller.value)` inside `AnimatedBuilder`.
