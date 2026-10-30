## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - CustomPainter Repaint & Object Allocation Optimization
**Learning:** `CustomPainter.shouldRepaint` defaulting to `true` causes canvas repaints on every parent widget rebuild regardless of whether paint inputs changed. Additionally, creating intermediate objects like `Rect.fromCircle` inside `paint()` during frame rendering causes unnecessary allocations.
**Action:** Always implement property comparison in `shouldRepaint` and cache local bounding shapes in `paint()`.
