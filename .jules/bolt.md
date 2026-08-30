## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Direct Type Casting on Drift Queries Fails
**Learning:** Drift-generated data classes (e.g., `BehavioralEventData`) do not inherit from domain models (`BehavioralEvent`). Using `.cast<BehavioralEvent>()` on query stream/future results causes runtime TypeErrors.
**Action:** Use explicit `.map(_mapToDomain)` transformation methods when returning domain models from Drift repository classes.
