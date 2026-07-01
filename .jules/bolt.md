## 2026-01-28 - Insights Engine and Provider Bottlenecks
**Learning:** Found N+1 query pattern in `InsightsNotifier.loadInsights` where database calls are made sequentially for each child. Also, `InsightsEngine` performs multiple O(N) passes (filtering and folding) over activity logs to calculate different metrics.
**Action:** Parallelize database fetches with `Future.wait` and refactor `InsightsEngine` to use a single-pass aggregation pattern.

## 2026-01-28 - Importance of Schema Preservation
**Learning:** Removing existing tables (like `Todos`) from the database schema during optimization can cause regressions or breaking changes, even if they appear unused in the current scope.
**Action:** Always preserve existing schema elements and focus on additive or performance-improving changes unless explicitly instructed to refactor the schema.

## 2026-01-28 - UI Overflow in Tests
**Learning:** Small surface sizes in tests (like 800x600) can trigger `RenderFlex` overflows that might not be obvious on a standard developer machine.
**Action:** Use `Expanded`, `Flexible`, and `TextOverflow.ellipsis` in `Row` and `Column` children to ensure layout robustness across different screen sizes.
