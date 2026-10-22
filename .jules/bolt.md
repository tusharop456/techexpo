## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use Future.wait to parallelize independent database fetches within providers.

## 2026-07-10 - Scoping Riverpod Providers to Leaf Widgets
**Learning:** Watching high-frequency dynamic providers (like AI insights) in top-level screen `ConsumerWidget`s causes the entire screen (including heavy chart subtrees) to rebuild on state changes.
**Action:** Extract dynamic sections into dedicated `ConsumerWidget` leaf widgets to scope `ref.watch()` updates and prevent re-rendering expensive parent UI trees.
