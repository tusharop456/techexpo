import 'package:flutter/material.dart';
import 'package:child_safety_monitor/core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1)),
            const SizedBox(height: 4),
            const Text('Manage your account and preferences', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            const SizedBox(height: 36),
            _buildSection('Account', [
              _SettingItem(icon: Icons.person_rounded, title: 'Profile', value: 'Tushar'),
              _SettingItem(icon: Icons.email_rounded, title: 'Email', value: 'john.doe@example.com'),
              _SettingItem(icon: Icons.lock_rounded, title: 'Password', value: '••••••••'),
            ]),
            const SizedBox(height: 28),
            _buildSection('Notifications', [
              _SettingToggle(icon: Icons.notifications_rounded, title: 'Push Notifications', value: true),
              _SettingToggle(icon: Icons.email_outlined, title: 'Email Alerts', value: true),
              _SettingToggle(icon: Icons.warning_amber_rounded, title: 'Critical Alerts Only', value: false),
            ]),
            const SizedBox(height: 28),
            _buildSection('Safety', [
              _SettingItem(icon: Icons.shield_rounded, title: 'Content Filtering', value: 'Strict'),
              _SettingItem(icon: Icons.schedule_rounded, title: 'Screen Time Limits', value: 'Enabled'),
              _SettingItem(icon: Icons.location_on_rounded, title: 'Location Tracking', value: 'Active'),
            ]),
            const SizedBox(height: 28),
            _buildSection('About', [
              _SettingItem(icon: Icons.info_rounded, title: 'Version', value: '1.0.0'),
              _SettingItem(icon: Icons.description_rounded, title: 'Terms of Service', value: ''),
              _SettingItem(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy', value: ''),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.glass.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.15)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SettingItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: value.isNotEmpty
          ? Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool value;

  const _SettingToggle({required this.icon, required this.title, required this.value});

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(widget.icon, color: AppColors.primary, size: 22),
      ),
      title: Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: Switch.adaptive(
        value: _value,
        onChanged: (v) => setState(() => _value = v),
        activeColor: AppColors.primary,
      ),
    );
  }
}
