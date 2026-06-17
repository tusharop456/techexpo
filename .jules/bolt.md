## 2025-05-15 - [Single-pass Aggregation Pattern]
**Learning:** Consolidating multiple `where`, `fold`, and `map` operations into a single loop with a helper aggregation class significantly reduces O(N) traversals, which is crucial for data-heavy service layers like `InsightsEngine`.
**Action:** Always look for redundant collection traversals in service logic and use a private metrics/aggregation class to collect all needed values in a single pass.

## 2025-05-15 - [Flutter Test Environment]
**Learning:** 'flutter test' may fail if assets defined in 'pubspec.yaml' (like '.env') are missing from the environment.
**Action:** Ensure a placeholder '.env' exists before running tests if the 'pubspec.yaml' references it.
