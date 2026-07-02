## 2024-07-02 - [Single-Pass Aggregation & Parallelized IO]
**Learning:** Consolidating multiple O(N) traversals into a single-pass loop is critical for data-heavy service layers. Parallelizing independent IO tasks with Future.wait avoids N+1 query patterns.
**Action:** Always check for multiple filter/fold calls on the same collection and replace with a single loop. Use Future.wait for independent async tasks in providers.
