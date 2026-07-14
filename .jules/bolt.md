## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - N+1 Bottleneck in Insights Provider
**Learning:** The insights provider was fetching database records sequentially for each child in a family. This creates an N+1 query pattern that scales poorly.
**Action:** Use batch database queries (e.g., `isIn`) to fetch data for multiple entities in a single round-trip, then partition in-memory.

## 2026-07-10 - Drift Query Limitation
**Learning:** Discovered that high-level Drift query builders (like `selectOnly`) might not support certain SQL features like `HAVING` in older versions, causing analyzer errors.
**Action:** When Drift's high-level API fails, fetch aggregated results and filter in-memory, or use `customSelect` for complex SQL.
