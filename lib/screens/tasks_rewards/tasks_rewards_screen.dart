import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

class TasksRewardsScreen extends ConsumerStatefulWidget {
  const TasksRewardsScreen({super.key});

  @override
  ConsumerState<TasksRewardsScreen> createState() => _TasksRewardsScreenState();
}

class _TasksRewardsScreenState extends ConsumerState<TasksRewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildPointsSummary(),
            const SizedBox(height: 28),
            _buildTabSection(),
            const SizedBox(height: 28),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tasks & Rewards', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Earn stars by completing tasks!', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
            child: const Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 28),
                SizedBox(width: 8),
                Text('245', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummary() {
    final stats = [
      {'label': 'This Week', 'value': '+85', 'icon': Icons.trending_up_rounded, 'color': const Color(0xFF10B981)},
      {'label': 'Tasks Done', 'value': '12', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF6366F1)},
      {'label': 'Streak', 'value': '5 days', 'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFEF4444)},
      {'label': 'Level', 'value': 'Gold', 'icon': Icons.workspace_premium_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return Row(
      children: stats.map((stat) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: stat != stats.last ? 16 : 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: (stat['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat['value'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(stat['label'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Today\'s Tasks'),
                Tab(text: 'Rewards Shop'),
                Tab(text: 'History'),
              ],
            ),
          ),
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksList(),
                _buildRewardsShop(),
                _buildHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    final tasks = [
      {'title': 'Complete Homework', 'desc': 'Finish math worksheet', 'stars': 25, 'done': false, 'icon': Icons.book_rounded, 'color': const Color(0xFF6366F1)},
      {'title': 'Read for 30 mins', 'desc': 'Any book of your choice', 'stars': 15, 'done': true, 'icon': Icons.auto_stories_rounded, 'color': const Color(0xFF10B981)},
      {'title': 'Clean Your Room', 'desc': 'Tidy up and organize', 'stars': 20, 'done': false, 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Screen Break', 'desc': 'Take a 15-min break from screens', 'stars': 10, 'done': true, 'icon': Icons.visibility_off_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'Help with Dinner', 'desc': 'Set the table or help cook', 'stars': 15, 'done': false, 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'Outdoor Activity', 'desc': 'Play outside for 30 mins', 'stars': 20, 'done': false, 'icon': Icons.directions_run_rounded, 'color': const Color(0xFF14B8A6)},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isDone = task['done'] as bool;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDone ? AppColors.success.withValues(alpha: 0.05) : AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDone ? AppColors.success.withValues(alpha: 0.3) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.success : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDone ? AppColors.success : Colors.grey.shade400, width: 2),
                    ),
                    child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: (task['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(task['icon'] as IconData, color: task['color'] as Color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(task['desc'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isDone ? null : const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
                    color: isDone ? Colors.grey.shade200 : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: isDone ? Colors.grey : Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${task['stars']}',
                        style: TextStyle(color: isDone ? Colors.grey : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardsShop() {
    final rewards = [
      {'title': '30 min Extra Screen Time', 'stars': 50, 'icon': Icons.phone_android_rounded, 'color': const Color(0xFF6366F1)},
      {'title': 'Choose Dinner', 'stars': 75, 'icon': Icons.restaurant_menu_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'Movie Night Pick', 'stars': 60, 'icon': Icons.movie_rounded, 'color': const Color(0xFF8B5CF6)},
      {'title': 'Stay Up Late (Weekend)', 'stars': 100, 'icon': Icons.bedtime_rounded, 'color': const Color(0xFF14B8A6)},
      {'title': 'New App Download', 'stars': 80, 'icon': Icons.download_rounded, 'color': const Color(0xFF10B981)},
      {'title': '₹50 Allowance Bonus', 'stars': 150, 'icon': Icons.currency_rupee_rounded, 'color': const Color(0xFFF59E0B)},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.3),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          final canAfford = 245 >= (reward['stars'] as int);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: canAfford
                  ? LinearGradient(colors: [(reward['color'] as Color).withValues(alpha: 0.08), (reward['color'] as Color).withValues(alpha: 0.02)])
                  : null,
              color: canAfford ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: canAfford ? (reward['color'] as Color).withValues(alpha: 0.3) : Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: canAfford ? (reward['color'] as Color).withValues(alpha: 0.15) : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(reward['icon'] as IconData, color: canAfford ? reward['color'] as Color : Colors.grey, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  reward['title'] as String,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: canAfford ? AppColors.textPrimary : Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: canAfford ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]) : null,
                    color: canAfford ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: canAfford ? Colors.white : Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text('${reward['stars']}', style: TextStyle(color: canAfford ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistory() {
    final history = [
      {'action': 'Completed: Read for 30 mins', 'stars': '+15', 'time': '2 hours ago', 'type': 'earned'},
      {'action': 'Redeemed: 30 min Extra Screen Time', 'stars': '-50', 'time': 'Yesterday', 'type': 'spent'},
      {'action': 'Completed: Screen Break', 'stars': '+10', 'time': 'Yesterday', 'type': 'earned'},
      {'action': 'Completed: Help with Dinner', 'stars': '+15', 'time': '2 days ago', 'type': 'earned'},
      {'action': 'Redeemed: Choose Dinner', 'stars': '-75', 'time': '3 days ago', 'type': 'spent'},
      {'action': 'Completed: Outdoor Activity', 'stars': '+20', 'time': '3 days ago', 'type': 'earned'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = history[index];
          final isEarned = item['type'] == 'earned';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isEarned ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isEarned ? Icons.add_circle_rounded : Icons.remove_circle_rounded, color: isEarned ? AppColors.success : AppColors.warning, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['action'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text(item['time'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  item['stars'] as String,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isEarned ? AppColors.success : AppColors.warning),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star_rounded, color: isEarned ? AppColors.success : AppColors.warning, size: 18),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'title': 'Early Bird', 'desc': 'Complete 5 tasks before noon', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFF59E0B), 'earned': true},
      {'title': 'Bookworm', 'desc': 'Read for 7 days in a row', 'icon': Icons.auto_stories_rounded, 'color': const Color(0xFF6366F1), 'earned': true},
      {'title': 'Screen Master', 'desc': 'Stay under screen limit for 5 days', 'icon': Icons.tv_off_rounded, 'color': const Color(0xFF10B981), 'earned': false, 'progress': 0.6},
      {'title': 'Helper Hero', 'desc': 'Complete 10 chore tasks', 'icon': Icons.volunteer_activism_rounded, 'color': const Color(0xFFEF4444), 'earned': false, 'progress': 0.8},
      {'title': 'Star Collector', 'desc': 'Earn 500 stars total', 'icon': Icons.star_rounded, 'color': const Color(0xFF8B5CF6), 'earned': false, 'progress': 0.49},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 10),
            Text('Achievements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: achievements.map((a) {
            final earned = a['earned'] as bool;
            return Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: earned
                    ? LinearGradient(colors: [(a['color'] as Color).withValues(alpha: 0.15), (a['color'] as Color).withValues(alpha: 0.05)])
                    : null,
                color: earned ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: earned ? (a['color'] as Color).withValues(alpha: 0.4) : Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: earned ? (a['color'] as Color).withValues(alpha: 0.2) : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a['icon'] as IconData, color: earned ? a['color'] as Color : Colors.grey, size: 22),
                      ),
                      if (earned) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(a['title'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: earned ? AppColors.textPrimary : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(a['desc'] as String, style: TextStyle(fontSize: 12, color: earned ? AppColors.textSecondary : Colors.grey.shade500)),
                  if (!earned && a['progress'] != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: a['progress'] as double,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(a['color'] as Color),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${((a['progress'] as double) * 100).toInt()}% complete', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
