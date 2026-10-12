## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - CustomPainter Repaint Optimization in Gauge Widgets
**Learning:** Returning `true` unconditionally from `CustomPainter.shouldRepaint` forces Flutter to re-draw canvas operations on every parent widget rebuild, leading to unnecessary CPU/GPU canvas rendering and object allocations.
**Action:** Always implement property equality comparisons in `shouldRepaint` (e.g. `oldDelegate.score != score || oldDelegate.color != color`) and cache bounds/rects in `paint()`.
