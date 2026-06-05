import 'dart:math';
import 'package:child_safety_monitor/data/models/activity_log.dart';

/// Utility class to generate realistic demo data for competition presentations.
/// The data is dynamic (based on DateTime.now()) so it always looks current.
class DemoDataGenerator {
  static final _random = Random(42); // Seeded for consistent "randomness"

  /// App name mappings for each category
  static const _appsByCategory = {
    ActivityCategory.education: ['Khan Academy', 'Duolingo', 'Photomath', 'Quizlet', 'Google Classroom'],
    ActivityCategory.gaming: ['Roblox', 'Minecraft', 'Fortnite', 'Clash Royale', 'Brawl Stars'],
    ActivityCategory.social: ['Moj', 'Instagram', 'Snapchat', 'Discord', 'WhatsApp'],
    ActivityCategory.entertainment: ['YouTube', 'Netflix', 'Spotify', 'Disney+', 'Twitch'],
  };

  /// Generate a random duration within a range (for organic-looking data)
  static int _randomMinutes(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  /// Get a random app name for a category
  static String _randomApp(ActivityCategory category) {
    final apps = _appsByCategory[category] ?? ['Unknown App'];
    return apps[_random.nextInt(apps.length)];
  }

  /// Generate demo activity logs for a specific child
  /// 
  /// Stories:
  /// - 'child_1' (Emma): Positive trend - high education, moderate social
  /// - 'child_2' (Liam): Negative anomaly - massive gaming spike yesterday
  static List<ActivityLog> getDemoLogsFor(String childId) {
    switch (childId) {
      case 'child_1':
        return _generateEmmaLogs();
      case 'child_2':
        return _generateLiamLogs();
      default:
        return _generateGenericLogs(childId);
    }
  }

  /// Emma's Story: The Star Student 🌟
  /// High education usage, moderate social, low gaming
  static List<ActivityLog> _generateEmmaLogs() {
    final logs = <ActivityLog>[];
    final now = DateTime.now();
    int logId = 1;

    // Generate 7 days of data
    for (int daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final day = now.subtract(Duration(days: daysAgo));
      
      // Education: 60-90 mins (star student!)
      logs.add(ActivityLog(
        id: 'emma_${logId++}',
        childId: 'child_1',
        screenTime: _randomMinutes(60, 90),
        timestamp: DateTime(day.year, day.month, day.day, 16, 30), // After school
        category: ActivityCategory.education,
        appName: 'Khan Academy',
      ));
      
      // Duolingo: 15-25 mins
      logs.add(ActivityLog(
        id: 'emma_${logId++}',
        childId: 'child_1',
        screenTime: _randomMinutes(15, 25),
        timestamp: DateTime(day.year, day.month, day.day, 17, 30),
        category: ActivityCategory.education,
        appName: 'Duolingo',
      ));

      // Social Media: 20-35 mins (moderate)
      logs.add(ActivityLog(
        id: 'emma_${logId++}',
        childId: 'child_1',
        screenTime: _randomMinutes(20, 35),
        timestamp: DateTime(day.year, day.month, day.day, 19, 0),
        category: ActivityCategory.social,
        appName: _randomApp(ActivityCategory.social),
      ));

      // Entertainment: 25-40 mins (evening relaxation)
      logs.add(ActivityLog(
        id: 'emma_${logId++}',
        childId: 'child_1',
        screenTime: _randomMinutes(25, 40),
        timestamp: DateTime(day.year, day.month, day.day, 20, 0),
        category: ActivityCategory.entertainment,
        appName: 'YouTube',
      ));

      // Gaming: Only 10-20 mins (balanced)
      logs.add(ActivityLog(
        id: 'emma_${logId++}',
        childId: 'child_1',
        screenTime: _randomMinutes(10, 20),
        timestamp: DateTime(day.year, day.month, day.day, 18, 0),
        category: ActivityCategory.gaming,
        appName: 'Minecraft',
      ));
    }

    // Today: Extra education boost to trigger positive insight
    logs.add(ActivityLog(
      id: 'emma_${logId++}',
      childId: 'child_1',
      screenTime: 45,
      timestamp: DateTime(now.year, now.month, now.day, 15, 0),
      category: ActivityCategory.education,
      appName: 'Photomath',
    ));

    return logs;
  }

  /// Liam's Story: The Gaming Spike ⚠️
  /// Yesterday had a MASSIVE gaming session (4 hours!) to trigger AI warning
  static List<ActivityLog> _generateLiamLogs() {
    final logs = <ActivityLog>[];
    final now = DateTime.now();
    int logId = 1;

    // Generate 7 days of baseline data
    for (int daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final day = now.subtract(Duration(days: daysAgo));
      final isYesterday = daysAgo == 1;
      final isToday = daysAgo == 0;

      // Education: 20-35 mins (less than Emma)
      logs.add(ActivityLog(
        id: 'liam_${logId++}',
        childId: 'child_2',
        screenTime: _randomMinutes(20, 35),
        timestamp: DateTime(day.year, day.month, day.day, 16, 0),
        category: ActivityCategory.education,
        appName: 'Google Classroom',
      ));

      // Gaming: SPIKE YESTERDAY!
      if (isYesterday) {
        // 🔥 THE BIG SPIKE: 240 mins (4 hours!) of Roblox
        logs.add(ActivityLog(
          id: 'liam_${logId++}',
          childId: 'child_2',
          screenTime: 180, // 3 hours
          timestamp: DateTime(day.year, day.month, day.day, 14, 0),
          category: ActivityCategory.gaming,
          appName: 'Roblox',
        ));
        logs.add(ActivityLog(
          id: 'liam_${logId++}',
          childId: 'child_2',
          screenTime: 60, // 1 more hour
          timestamp: DateTime(day.year, day.month, day.day, 18, 0),
          category: ActivityCategory.gaming,
          appName: 'Minecraft',
        ));
      } else if (isToday) {
        // Today: Still high but less
        logs.add(ActivityLog(
          id: 'liam_${logId++}',
          childId: 'child_2',
          screenTime: _randomMinutes(60, 75),
          timestamp: DateTime(day.year, day.month, day.day, 15, 0),
          category: ActivityCategory.gaming,
          appName: 'Roblox',
        ));
      } else {
        // Normal days: 30-45 mins gaming
        logs.add(ActivityLog(
          id: 'liam_${logId++}',
          childId: 'child_2',
          screenTime: _randomMinutes(30, 45),
          timestamp: DateTime(day.year, day.month, day.day, 17, 0),
          category: ActivityCategory.gaming,
          appName: _randomApp(ActivityCategory.gaming),
        ));
      }

      // Social: 15-30 mins
      logs.add(ActivityLog(
        id: 'liam_${logId++}',
        childId: 'child_2',
        screenTime: _randomMinutes(15, 30),
        timestamp: DateTime(day.year, day.month, day.day, 19, 30),
        category: ActivityCategory.social,
        appName: 'Discord',
      ));

      // Entertainment: 30-50 mins
      logs.add(ActivityLog(
        id: 'liam_${logId++}',
        childId: 'child_2',
        screenTime: _randomMinutes(30, 50),
        timestamp: DateTime(day.year, day.month, day.day, 20, 30),
        category: ActivityCategory.entertainment,
        appName: 'YouTube',
      ));

      // Late night usage (yesterday only - triggers warning!)
      if (isYesterday) {
        logs.add(ActivityLog(
          id: 'liam_${logId++}',
          childId: 'child_2',
          screenTime: 45,
          timestamp: DateTime(day.year, day.month, day.day, 23, 30),
          category: ActivityCategory.gaming,
          appName: 'Roblox',
        ));
      }
    }

    return logs;
  }

  /// Generic logs for any other child (balanced usage)
  static List<ActivityLog> _generateGenericLogs(String childId) {
    final logs = <ActivityLog>[];
    final now = DateTime.now();
    int logId = 1;

    for (int daysAgo = 6; daysAgo >= 0; daysAgo--) {
      final day = now.subtract(Duration(days: daysAgo));

      for (final category in [
        ActivityCategory.education,
        ActivityCategory.gaming,
        ActivityCategory.social,
        ActivityCategory.entertainment,
      ]) {
        logs.add(ActivityLog(
          id: '${childId}_${logId++}',
          childId: childId,
          screenTime: _randomMinutes(20, 45),
          timestamp: DateTime(day.year, day.month, day.day, 14 + logId % 8, 0),
          category: category,
          appName: _randomApp(category),
        ));
      }
    }

    return logs;
  }

  /// Get all demo logs for all children
  static List<ActivityLog> getAllDemoLogs() {
    return [
      ...getDemoLogsFor('child_1'),
      ...getDemoLogsFor('child_2'),
    ];
  }

  /// Get today's logs only for a specific child
  static List<ActivityLog> getTodayLogsFor(String childId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    return getDemoLogsFor(childId)
        .where((log) => log.timestamp.isAfter(startOfToday))
        .toList();
  }

  /// Get historical logs (before today) for a specific child
  static List<ActivityLog> getHistoricalLogsFor(String childId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    
    return getDemoLogsFor(childId)
        .where((log) => log.timestamp.isBefore(startOfToday))
        .toList();
  }
}
