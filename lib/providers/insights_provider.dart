import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/data/database/app_database.dart';
import 'package:child_safety_monitor/data/models/activity_log.dart';
import 'package:child_safety_monitor/services/insights_engine.dart';
import 'package:child_safety_monitor/services/gemini_insight_service.dart';
import 'package:child_safety_monitor/utils/demo_data_generator.dart';

/// Provider for AppDatabase instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// State class for insights
class InsightsState {
  final List<Insight> insights;
  final bool isLoading;
  final bool hasEnoughData;
  final String? error;

  const InsightsState({
    this.insights = const [],
    this.isLoading = true,
    this.hasEnoughData = true,
    this.error,
  });

  InsightsState copyWith({
    List<Insight>? insights,
    bool? isLoading,
    bool? hasEnoughData,
    String? error,
  }) {
    return InsightsState(
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      hasEnoughData: hasEnoughData ?? this.hasEnoughData,
      error: error,
    );
  }
}

/// InsightsNotifier - Manages AI insights state
class InsightsNotifier extends StateNotifier<InsightsState> {
  final AppDatabase _db;
  
  InsightsNotifier(this._db) : super(const InsightsState()) {
    loadInsights();
  }
  
  /// Load insights from database
  Future<void> loadInsights() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final children = await _db.getAllChildren();
      
      if (children.isEmpty) {
        state = state.copyWith(
          insights: [],
          isLoading: false,
          hasEnoughData: false,
        );
        return;
      }
      
      // BOLT OPTIMIZATION: Batch database queries to reduce round-trips (3 total)
      final childIds = children.map((c) => c.id).toList();
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);

      // 1. Fetch all relevant data in parallel batches
      final batchResults = await Future.wait([
        _db.getManyHasEnoughData(childIds),
        _db.getAllLast7DaysLogs(childIds),
      ]);

      final hasDataMap = batchResults[0] as Set<String>;
      final allLogs = batchResults[1] as List<ActivityLogEntry>;

      // 2. Partition logs by childId and split into today/historical in memory
      final logsByChild = <String, List<ActivityLog>>{};
      for (final e in allLogs) {
        final log = ActivityLog(
          id: e.id,
          childId: e.childId,
          screenTime: e.screenTime,
          timestamp: e.timestamp,
          category: _parseCategory(e.category),
          appName: e.appName,
        );
        logsByChild.putIfAbsent(log.childId, () => []).add(log);
      }

      final allInsights = <Insight>[];
      bool hasAnyData = hasDataMap.isNotEmpty;

      // 3. Process insights for each child using partitioned data
      for (final child in children) {
        final childLogs = logsByChild[child.id] ?? [];
        final historical = <ActivityLog>[];
        final todayLogs = <ActivityLog>[];

        for (final log in childLogs) {
          if (log.timestamp.isAfter(startOfToday)) {
            todayLogs.add(log);
          } else {
            historical.add(log);
          }
        }

        final childInsights = InsightsEngine.generateDailyInsights(
          childId: child.id,
          childName: child.name,
          historicalData: historical,
          todayData: todayLogs,
        );
        allInsights.addAll(childInsights);
      }
      
      // If no real insights generated, use demo insights
      if (allInsights.isEmpty) {
        allInsights.addAll(InsightsEngine.generateDemoInsights());
      }
      
      // Sort by timestamp (newest first)
      allInsights.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      state = state.copyWith(
        insights: allInsights,
        isLoading: false,
        hasEnoughData: hasAnyData || allInsights.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasEnoughData: false,
        error: e.toString(),
      );
      // Fall back to demo insights on error
      state = state.copyWith(
        insights: InsightsEngine.generateDemoInsights(),
      );
    }
  }
  
  /// Refresh insights
  Future<void> refresh() async {
    await loadInsights();
  }
  
  /// Refresh insights for a specific child using demo data (for competition demo)
  /// This uses the DemoDataGenerator to create realistic test data
  Future<void> refreshInsightsForChild(String childId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Get child name from ID
      final childName = childId == 'child_1' ? 'Ananya' : 
                        childId == 'child_2' ? 'Arjun' : 'Child';
      
      // Get demo data
      final historicalLogs = DemoDataGenerator.getHistoricalLogsFor(childId);
      final todayLogs = DemoDataGenerator.getTodayLogsFor(childId);
      
      // Generate local insights first
      final localInsights = InsightsEngine.generateDailyInsights(
        childId: childId,
        childName: childName,
        historicalData: historicalLogs,
        todayData: todayLogs,
      );
      
      List<Insight> allInsights = [...localInsights];
      
      // Try to get AI-enhanced insights from Gemini
      if (geminiService.isConfigured) {
        try {
          final aiInsights = await geminiService.generateInsights(
            childId: childId,
            childName: childName,
            historicalData: historicalLogs,
            todayData: todayLogs,
          );
          // Add unique AI insights
          for (final insight in aiInsights) {
            if (!allInsights.any((i) => i.title == insight.title)) {
              allInsights.add(insight);
            }
          }
        } catch (e) {
          // Gemini failed, continue with local insights
          print('Gemini API failed: $e');
        }
      }
      
      // Sort by type priority (anomaly > warning > positive > neutral)
      allInsights.sort((a, b) {
        final priority = {
          InsightType.anomaly: 0,
          InsightType.warning: 1,
          InsightType.positive: 2,
          InsightType.neutral: 3,
        };
        return (priority[a.type] ?? 4).compareTo(priority[b.type] ?? 4);
      });
      
      state = state.copyWith(
        insights: allInsights,
        isLoading: false,
        hasEnoughData: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Dismiss an insight
  void dismissInsight(String insightId) {
    state = state.copyWith(
      insights: state.insights.where((i) => i.id != insightId).toList(),
    );
  }
  
  /// Convert string category to enum
  ActivityCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'gaming':
        return ActivityCategory.gaming;
      case 'social':
        return ActivityCategory.social;
      case 'education':
        return ActivityCategory.education;
      case 'entertainment':
        return ActivityCategory.entertainment;
      case 'productivity':
        return ActivityCategory.productivity;
      default:
        return ActivityCategory.other;
    }
  }
}

/// Provider for insights state
final insightsProvider = StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  final db = ref.watch(databaseProvider);
  return InsightsNotifier(db);
});

/// Provider for just the insights list
final insightsListProvider = Provider<List<Insight>>((ref) {
  return ref.watch(insightsProvider).insights;
});

/// Provider for loading state
final insightsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(insightsProvider).isLoading;
});

/// Provider for checking if there's enough data
final hasEnoughDataProvider = Provider<bool>((ref) {
  return ref.watch(insightsProvider).hasEnoughData;
});
