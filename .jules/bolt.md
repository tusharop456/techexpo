## 2026-06-21 - Optimized InsightsEngine with single-pass aggregation
**Learning:** Consolidating multiple O(N) traversals (filtering, mapping, folding) into a single loop significantly reduces processing overhead for large data sets. Additionally, utilizing SQL aggregate functions (AVG, COUNT) in the database layer is far more efficient than fetching all records and processing them in Dart.
**Action:** Always look for opportunities to replace redundant collection traversals with a single-pass aggregation pattern. Ensure database queries use aggregate functions for metrics calculation.
