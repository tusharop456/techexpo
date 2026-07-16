## 2026-07-10 - Single-pass Aggregation in Insights Engine
**Learning:** Found that the InsightsEngine was performing multiple O(N) traversals on ActivityLog lists for different metrics (screen time, category filtering, anomaly detection). Consolidating these into a single loop reduces complexity significantly.
**Action:** Use a private aggregation class and a single-pass loop for batch data processing in service layers.

## 2026-07-10 - Batch Database Queries for AI Insights
**Learning:** Even with parallelization (Future.wait), sequential N+1 patterns (3 queries per child) still put significant pressure on the SQLite connection pool and increase latency. Batching queries using `isIn` and `groupBy` allows fetching data for ALL children in just 2-3 queries.
**Action:** Implement batch query methods in the database layer and use in-memory partitioning to group results by entity ID.
