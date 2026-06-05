import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:child_safety_monitor/core/constants/app_colors.dart';
import 'package:child_safety_monitor/data/models/screen_time_rule.dart';

/// Smart Screen Time Rules Screen
class SmartRulesScreen extends StatefulWidget {
  const SmartRulesScreen({super.key});

  @override
  State<SmartRulesScreen> createState() => _SmartRulesScreenState();
}

class _SmartRulesScreenState extends State<SmartRulesScreen> {
  List<ScreenTimeRule> _rules = [];
  ScreenTimeSuggestion? _aiSuggestion;
  bool _isLoadingSuggestion = false;
  String? _activeMode;

  // Preset modes with default configurations
  final List<Map<String, dynamic>> _presetModes = [
    {
      'id': 'homework',
      'name': 'Homework Time',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF667EEA),
      'description': 'Block games & social media',
      'allowed': ['Education', 'Productivity'],
      'blocked': ['Gaming', 'Social Media', 'Entertainment'],
    },
    {
      'id': 'bedtime',
      'name': 'Bedtime Mode',
      'icon': Icons.bedtime_rounded,
      'color': const Color(0xFF764BA2),
      'description': 'Only calls allowed',
      'allowed': ['Calls'],
      'blocked': ['Everything else'],
    },
    {
      'id': 'freetime',
      'name': 'Free Time',
      'icon': Icons.sports_esports_rounded,
      'color': const Color(0xFF10B981),
      'description': 'All apps with time limit',
      'allowed': ['All Apps'],
      'blocked': [],
    },
    {
      'id': 'school',
      'name': 'School Mode',
      'icon': Icons.school_rounded,
      'color': const Color(0xFFF59E0B),
      'description': 'Block all apps',
      'allowed': [],
      'blocked': ['All Apps'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultRules();
  }

  void _loadDefaultRules() {
    _rules = [
      ScreenTimeRule(
        id: '1',
        name: 'Homework Time',
        description: 'Focus on studies without distractions',
        mode: ScreenTimeMode.homework,
        startTime: '15:00',
        endTime: '17:00',
        allowedCategories: ['Education', 'Productivity'],
        blockedCategories: ['Gaming', 'Social Media', 'Entertainment'],
        isActive: false,
        activeDays: [0, 1, 2, 3, 4], // Mon-Fri
      ),
      ScreenTimeRule(
        id: '2',
        name: 'Bedtime Mode',
        description: 'Wind down before sleep',
        mode: ScreenTimeMode.bedtime,
        startTime: '21:00',
        endTime: '07:00',
        allowedCategories: ['Calls'],
        blockedCategories: ['All Apps'],
        isActive: false,
        activeDays: [0, 1, 2, 3, 4, 5, 6],
      ),
    ];
  }

  Future<void> _getAISuggestions() async {
    setState(() => _isLoadingSuggestion = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/screentime/suggest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_name': 'Ananya',
          'child_age': 10,
          'usage_data': [
            {'category': 'Gaming', 'avg_daily_minutes': 120, 'peak_hours': ['16:00', '20:00']},
            {'category': 'Social Media', 'avg_daily_minutes': 45, 'peak_hours': ['18:00']},
            {'category': 'Education', 'avg_daily_minutes': 60, 'peak_hours': ['15:00']},
            {'category': 'Entertainment', 'avg_daily_minutes': 90, 'peak_hours': ['19:00']},
          ],
          'current_bedtime': '21:00',
          'school_hours': '08:00-14:30',
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _aiSuggestion = ScreenTimeSuggestion.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
    }

    setState(() => _isLoadingSuggestion = false);
  }

  void _activateMode(String modeId) {
    setState(() {
      _activeMode = _activeMode == modeId ? null : modeId;
    });
  }

  void _toggleRule(ScreenTimeRule rule) {
    setState(() {
      final index = _rules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _rules[index] = rule.copyWith(isActive: !rule.isActive);
      }
    });
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
            const SizedBox(height: 32),
            _buildQuickModes(),
            const SizedBox(height: 32),
            _buildAISuggestionCard(),
            const SizedBox(height: 32),
            _buildScheduledRules(),
            if (_aiSuggestion != null) ...[
              const SizedBox(height: 32),
              _buildAIInsights(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Screen Time Rules',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'AI-powered rules for healthy screen habits',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Modes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap to activate instantly',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: _presetModes.length,
          itemBuilder: (context, index) {
            final mode = _presetModes[index];
            final isActive = _activeMode == mode['id'];
            final Color color = mode['color'] as Color;

            return GestureDetector(
              onTap: () => _activateMode(mode['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                      : null,
                  color: isActive ? null : AppColors.glass.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? color : AppColors.glassBorder.withValues(alpha: 0.15),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16)]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mode['icon'] as IconData,
                      color: isActive ? Colors.white : color,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mode['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode['description'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAISuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withValues(alpha: 0.15),
            const Color(0xFF764BA2).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Suggestions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Get personalized rules based on usage patterns',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoadingSuggestion ? null : _getAISuggestions,
                icon: _isLoadingSuggestion
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.psychology_rounded, size: 20),
                label: Text(_isLoadingSuggestion ? 'Analyzing...' : 'Get Suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (_aiSuggestion != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glass.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Recommendation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _aiSuggestion!.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRecommendationChip(
                        Icons.timer_rounded,
                        '${_aiSuggestion!.recommendedDailyLimit} min/day',
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      _buildRecommendationChip(
                        Icons.bedtime_rounded,
                        'Bedtime: ${_aiSuggestion!.recommendedBedtime}',
                        const Color(0xFF764BA2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Suggested Rules:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...(_aiSuggestion!.suggestedRules.map((rule) => _buildSuggestedRuleCard(rule))),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedRuleCard(SuggestedRule rule) {
    final color = _getModeColor(rule.modeName);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getModeIcon(rule.modeName), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.modeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rule.startTime} - ${rule.endTime}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _applyAISuggestion(rule),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _applyAISuggestion(SuggestedRule rule) {
    final newRule = ScreenTimeRule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: rule.modeName,
      description: rule.description,
      mode: _parseMode(rule.modeName),
      startTime: rule.startTime,
      endTime: rule.endTime,
      allowedCategories: rule.allowedCategories,
      blockedCategories: rule.blockedCategories,
      dailyLimitMinutes: rule.dailyLimitMinutes,
      isActive: true,
    );
    
    setState(() {
      _rules.add(newRule);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${rule.modeName} rule added!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  ScreenTimeMode _parseMode(String name) {
    if (name.toLowerCase().contains('homework')) return ScreenTimeMode.homework;
    if (name.toLowerCase().contains('bedtime')) return ScreenTimeMode.bedtime;
    if (name.toLowerCase().contains('school')) return ScreenTimeMode.school;
    if (name.toLowerCase().contains('free')) return ScreenTimeMode.freeTime;
    return ScreenTimeMode.custom;
  }

  Color _getModeColor(String modeName) {
    if (modeName.toLowerCase().contains('homework')) return const Color(0xFF667EEA);
    if (modeName.toLowerCase().contains('bedtime')) return const Color(0xFF764BA2);
    if (modeName.toLowerCase().contains('school')) return const Color(0xFFF59E0B);
    if (modeName.toLowerCase().contains('free')) return const Color(0xFF10B981);
    return const Color(0xFF667EEA);
  }

  IconData _getModeIcon(String modeName) {
    if (modeName.toLowerCase().contains('homework')) return Icons.menu_book_rounded;
    if (modeName.toLowerCase().contains('bedtime')) return Icons.bedtime_rounded;
    if (modeName.toLowerCase().contains('school')) return Icons.school_rounded;
    if (modeName.toLowerCase().contains('free')) return Icons.sports_esports_rounded;
    return Icons.schedule_rounded;
  }

  Widget _buildScheduledRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text(
              'Scheduled Rules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_rules.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.glass.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No scheduled rules yet. Get AI suggestions or activate a quick mode!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...(_rules.map((rule) => _buildRuleCard(rule))),
      ],
    );
  }

  Widget _buildRuleCard(ScreenTimeRule rule) {
    final color = _getModeColor(rule.name);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: rule.isActive ? color.withValues(alpha: 0.4) : AppColors.glassBorder.withValues(alpha: 0.15),
          width: rule.isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (rule.isActive ? color : AppColors.textSecondary).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getModeIcon(rule.name),
              color: rule.isActive ? color : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (rule.isActive) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${rule.startTime} - ${rule.endTime}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    if (rule.blockedCategories.isNotEmpty)
                      ...rule.blockedCategories.take(2).map((cat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🚫 $cat',
                          style: const TextStyle(fontSize: 11, color: AppColors.error),
                        ),
                      )),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: rule.isActive,
            onChanged: (value) => _toggleRule(rule),
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 10),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_aiSuggestion!.insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontSize: 14)),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ))),
        ],
      ),
    );
  }
}
