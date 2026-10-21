## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-11 - CustomPainter Repaint Optimization & Bounding Rect Caching
**Learning:** CustomPainter classes with `shouldRepaint => true` cause canvas redraws on every parent rebuild frame (e.g. text input state updates), causing unnecessary canvas redraw operations and redundant Rect allocations.
**Action:** Implement parameter comparison in `shouldRepaint` and cache bounding `Rect` instances inside `paint` to prevent unnecessary repaints and object allocations.
