## 2026-07-07 - Parallelized Data Fetching in Riverpod Notifiers
**Learning:** Sequential 'await' calls in a loop for database queries (N children * 3 queries/child) create a significant I/O bottleneck. Parallelizing these with Future.wait reduces total latency from O(N) to effectively O(1) query rounds.
**Action:** Always look for independent asynchronous calls within loops and consolidate them using Future.wait to minimize I/O wait times.
