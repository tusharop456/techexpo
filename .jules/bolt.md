## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Single-Pass Aggregation in UI Tab Views
**Learning:** In Flutter screen build methods (e.g., AlertsScreen), computing multiple tab metrics using repeated `.where()` filters results in N separate linear traversals on every render frame.
**Action:** Consolidate list filtering and counting into a single O(N) loop in `build()` and pass pre-partitioned lists to child tab widgets.
