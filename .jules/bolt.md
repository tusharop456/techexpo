## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-10-18 - Direct Collection For-Loops vs. Chained Iterable Mapping in Widget Trees
**Learning:** In Flutter widget build methods, using `list.take(N).toList().asMap().entries.map(...)` or `...list.map(...)` inside parent widget children lists creates multiple intermediate list, map, and entry allocations on every frame build.
**Action:** Replace chained iterable maps in widget trees with direct collection `for` loops (`for (int i = 0; ...; i++)` or `for (final item in list)`).
