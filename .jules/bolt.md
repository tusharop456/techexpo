## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Consolidated AnimationControllers in StaggeredList
**Learning:** Instantiating individual animated wrapper widgets (`FadeSlideIn`) for items in list animations creates N separate `AnimationController`s, `Ticker`s, and delayed timers.
**Action:** Use a single parent `AnimationController` with progress-based `Interval` curves transformed statelessly per item inside `AnimatedBuilder`.
