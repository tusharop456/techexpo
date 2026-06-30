## 2026-01-29 - [Baseline Verification]
**Learning:** In projects using code generation (like Drift/build_runner), the codebase may have significant hidden debt (missing tables, unimplemented methods in providers) that prevents even basic compilation.
**Action:** Always run 'flutter analyze' first to ensure a healthy baseline before applying optimizations.

## 2026-01-29 - [Parallel Fetch Optimization]
**Learning:** Sequential 'await' calls in loops for independent database queries create a linear performance penalty (O(N*M)) where N is the number of entities and M is the number of queries per entity.
**Action:** Use 'Future.wait' to parallelize independent database fetches, reducing latency to approximately the time of the longest single fetch.
