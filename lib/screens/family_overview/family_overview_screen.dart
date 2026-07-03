import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/providers/insights_provider.dart';
import 'package:child_safety_monitor/data/models/app_models.dart';
import 'package:child_safety_monitor/widgets/smart_insight_card.dart';
import 'package:child_safety_monitor/widgets/no_insights_widget.dart';
import 'package:child_safety_monitor/screens/child_profile/child_profile_screen.dart';

class FamilyOverviewScreen extends ConsumerWidget {
  const FamilyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final alertCount = ref.watch(unreadAlertCountProvider);
    final activeCount = ref.watch(activeChildrenCountProvider);
    final avgRisk = ref.watch(averageRiskProvider);
    final activities = ref.watch(activitiesProvider);
    final insightsState = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(children.length),
            const SizedBox(height: 28),
            // AI Insights Section (right after welcome banner)
            _buildInsightsSection(insightsState, ref),
            const SizedBox(height: 28),
            _buildStatsRow(alertCount, activeCount, avgRisk),
            const SizedBox(height: 36),
            _buildSectionHeader('Your Children', 'Monitor activity and safety', () => _showAddDialog(context, ref)),
            const SizedBox(height: 20),
            _buildChildrenCards(children, context, ref),
            const SizedBox(height: 36),
            _buildSectionHeader('Recent Activity', 'Latest events from your family', null),
            const SizedBox(height: 20),
            _buildActivityList(activities),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(InsightsState state, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
                  Text('Smart analysis of digital habits', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!state.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Live', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
              onPressed: () => ref.read(insightsProvider.notifier).refresh(),
              tooltip: 'Refresh insights',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (!state.hasEnoughData)
          const NoInsightsWidget()
        else
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.insights.length > 5 ? 5 : state.insights.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final insight = state.insights[index];
                return SizedBox(
                  width: 340,
                  child: SmartInsightCard(
                    insight: insight,
                    onDismiss: () => ref.read(insightsProvider.notifier).dismissInsight(insight.id),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(int childCount) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text('Welcome back!', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Family Safety Dashboard',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Text(
                  'All systems normal • $childCount children monitored',
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.verified_user_rounded, size: 52, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int alertCount, int activeCount, int avgRisk) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Alerts', '$alertCount', Icons.notifications_rounded, AppColors.warning, 'This week')),
        const SizedBox(width: 20),
        Expanded(child: _buildStatCard('Active Now', '$activeCount', Icons.person_rounded, AppColors.success, 'Children online')),
        const SizedBox(width: 20),
        Expanded(child: _buildStatCard('Avg Risk', '$avgRisk%', Icons.shield_rounded, AppColors.getRiskColor(avgRisk), 'Family score')),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, VoidCallback? onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        if (onAdd != null)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }

  Widget _buildChildrenCards(List<ChildModel> children, BuildContext context, WidgetRef ref) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.glass.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.2), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.glass, shape: BoxShape.circle),
              child: Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text('No children added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Click "Add Child" to get started', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: children.map((child) => _buildChildCard(child, context, ref)).toList(),
    );
  }

  Widget _buildChildCard(ChildModel child, BuildContext context, WidgetRef ref) {
    final riskColor = AppColors.getRiskColor(child.riskLevel);
    final initials = child.name.isNotEmpty ? child.name[0].toUpperCase() : '?';
    final status = child.riskLevel <= 40 ? 'Safe' : 'Needs Attention';
    final lastActiveText = _formatTime(child.lastActive);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildProfileScreen(childId: child.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.glass.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: riskColor.withValues(alpha: 0.35), width: 2),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [riskColor.withValues(alpha: 0.8), riskColor]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: riskColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text(initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text(child.deviceName, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('${child.riskLevel}%', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: riskColor)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: AppColors.glass),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(status == 'Safe' ? Icons.check_circle_rounded : Icons.warning_rounded, size: 18, color: riskColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 14, color: riskColor, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        lastActiveText,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _showEditDialog(context, ref, child),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: const Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          Text('Edit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _confirmDelete(context, ref, child),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: const Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Text('Remove', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildActivityList(List<ActivityModel> activities) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          IconData icon;
          Color color;
          
          switch (a.iconType) {
            case 'school': icon = Icons.school_rounded; color = AppColors.success; break;
            case 'play': icon = Icons.play_circle_rounded; color = AppColors.primary; break;
            case 'game': icon = Icons.sports_esports_rounded; color = AppColors.secondary; break;
            case 'block': icon = Icons.block_rounded; color = AppColors.error; break;
            default: icon = Icons.info_rounded; color = AppColors.primary;
          }

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 22),
                ),
                title: Text(a.description, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                subtitle: Text(a.childName, style: TextStyle(fontSize: 13, color: color)),
                trailing: Text(_formatTime(a.timestamp), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
              if (i < activities.length - 1) Divider(height: 1, indent: 76, color: AppColors.glass),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('Add New Child'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Child\'s Name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(childrenProvider.notifier).addChild(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add Child'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, ChildModel child) {
    final controller = TextEditingController(text: child.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Child'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(childrenProvider.notifier).updateChild(child.id, name: controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ChildModel child) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Child'),
        content: Text('Remove "${child.name}" from monitoring?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(childrenProvider.notifier).removeChild(child.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}