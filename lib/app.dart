import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/screens/family_overview/family_overview_screen.dart';
import 'package:child_safety_monitor/screens/dashboard/dashboard_screen.dart';
import 'package:child_safety_monitor/screens/alerts/alerts_screen.dart';
import 'package:child_safety_monitor/screens/settings/settings_screen.dart';
import 'package:child_safety_monitor/screens/screen_time/screen_time_screen.dart';
import 'package:child_safety_monitor/screens/tasks_rewards/tasks_rewards_screen.dart';
import 'package:child_safety_monitor/screens/reports/weekly_report_screen.dart';
import 'package:child_safety_monitor/screens/content_scanner/content_scanner_screen.dart';
import 'package:child_safety_monitor/screens/screen_time/smart_rules_screen.dart';
import 'package:child_safety_monitor/providers/app_state.dart';
import 'package:child_safety_monitor/providers/database_provider.dart' hide unreadAlertCountProvider;
import 'package:child_safety_monitor/data/models/app_models.dart';

import 'package:child_safety_monitor/services/realtime_alert_service.dart';
import 'package:child_safety_monitor/widgets/alert_popup.dart';
import 'dart:async';


class ChildSafetyApp extends ConsumerStatefulWidget {
  const ChildSafetyApp({super.key});

  @override
  ConsumerState<ChildSafetyApp> createState() => _ChildSafetyAppState();
}

class _ChildSafetyAppState extends ConsumerState<ChildSafetyApp> {
  int _selectedIndex = 0;
  StreamSubscription<RealtimeAlert>? _alertSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Listen to real-time alerts
    _alertSubscription = realtimeAlertService.alertStream.listen(_handleAlert);
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  void _handleAlert(RealtimeAlert alert) {
    // Show popup when alert received
    final context = _navigatorKey.currentContext;
    if (context != null) {
      AlertOverlayManager.showAlert(context, alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    final unreadCount = ref.watch(unreadAlertCountProvider);

    final List<Widget> screens = [
      const FamilyOverviewScreen(),
      const DashboardScreen(),
      const ScreenTimeScreen(),
      const SmartRulesScreen(),  // Smart Screen Time Rules
      const AlertsScreen(),
      const TasksRewardsScreen(),
      _WeeklyReportWrapper(),  // Wrapper to fetch child from database
      const ContentScannerScreen(),  // AI Content Scanner
      _HistoryScreen(),
      _ChildrenScreen(),
      const SettingsScreen(),
    ];

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Child Safety Monitor',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        // Premium typography with Google Fonts Inter
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            if (isWide) _buildSideNav(unreadCount),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: isWide ? null : _buildBottomNav(),
      ),
    );
  }

  Widget _buildSideNav(int unreadCount) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.background,
          ],
        ),
        border: Border(
          right: BorderSide(
            color: AppColors.glassBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _buildLogo(),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Family'),
                _buildNavItem(1, Icons.analytics_rounded, 'Dashboard'),
                _buildNavItem(2, Icons.schedule_rounded, 'Screen Time'),
                _buildNavItem(3, Icons.auto_awesome_rounded, 'Smart Rules'),
                _buildNavItem(4, Icons.notifications_rounded, 'Alerts', badge: unreadCount),
                _buildNavItem(5, Icons.emoji_events_rounded, 'Tasks & Rewards'),
                _buildNavItem(6, Icons.assessment_rounded, 'Weekly Reports'),
                _buildNavItem(7, Icons.security_rounded, 'Content Scanner'),
                _buildNavItem(8, Icons.history_rounded, 'History'),
                _buildNavItem(9, Icons.people_rounded, 'Children'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFF1E3A5F)),
                ),
                _buildNavItem(10, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
          _buildUserProfile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final unreadCount = ref.watch(unreadAlertCountProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/icons/shield.svg',
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SafeGuard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Family Protection',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Notification Bell with Badge
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 3), // Go to Alerts
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(
                    'assets/icons/bell.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      unreadCount > 0 ? const Color(0xFF667EEA) : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {int badge = 0}) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tushar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('Premium Plan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex > 3 ? 3 : _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      backgroundColor: AppColors.surface,
      elevation: 8,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: "Home"),
        NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: "Dashboard"),
        NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: "Alerts"),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: "Settings"),
      ],
    );
  }
}

// History Screen
class _HistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Activity History', 'Track all activities and events'),
            const SizedBox(height: 32),
            ...activities.map((activity) => _buildTimelineItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTimelineItem(ActivityModel activity) {
    IconData icon;
    Color color;

    switch (activity.iconType) {
      case 'school': icon = Icons.school_rounded; color = AppColors.success; break;
      case 'play': icon = Icons.play_circle_rounded; color = AppColors.primary; break;
      case 'game': icon = Icons.sports_esports_rounded; color = AppColors.secondary; break;
      case 'block': icon = Icons.block_rounded; color = AppColors.error; break;
      default: icon = Icons.info_rounded; color = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.childName, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(activity.description, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(_formatTime(activity.timestamp), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// Children Management Screen
class _ChildrenScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPageHeader('Manage Children', 'Add or edit child profiles'),
                _buildAddButton(context, ref),
              ],
            ),
            const SizedBox(height: 32),
            if (children.isEmpty)
              _buildEmptyState()
            else
              ...children.map((child) => _buildChildCard(context, ref, child)),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _showAddDialog(context, ref),
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Add Child'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text('No children added', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Add your first child to start monitoring', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, WidgetRef ref, ChildModel child) {
    final initials = child.name.isNotEmpty ? child.name[0].toUpperCase() : '?';
    final riskColor = AppColors.getRiskColor(child.riskLevel);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [riskColor.withValues(alpha: 0.8), riskColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: riskColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(child.deviceName, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip('Risk: ${child.riskLevel}%', riskColor),
                    const SizedBox(width: 12),
                    _buildStatusChip(_formatTime(child.lastActive), AppColors.success, icon: Icons.access_time_rounded),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _showEditDialog(context, ref, child),
                color: AppColors.textSecondary,
                style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _confirmDelete(context, ref, child),
                color: AppColors.error,
                style: IconButton.styleFrom(backgroundColor: AppColors.error.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
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
            hintText: 'Enter name',
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

// Weekly Report Wrapper - Fetches child from database and shows selection
class _WeeklyReportWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenStreamProvider);
    
    return childrenAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00D9FF))),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Center(
          child: Text('Error loading children: $error', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (children) {
        if (children.isEmpty) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A1628),
            body: Center(
              child: Text(
                'No children found. Add a child first.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }
        
        // Use the first child by default (you can add a child selector here later)
        final child = children.first;
        return WeeklyReportScreen(
          childId: child.id,
          childName: child.name,
          childAge: 10, // Default age for now
        );
      },
    );
  }
}