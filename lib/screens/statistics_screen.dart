import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/stats_service.dart';
import '../models/session_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.darkBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.darkBackground,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
        ),
        middle: const Text(
          'Statistics',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Consumer<StatsService>(
          builder: (context, statsService, child) {
            final stats = statsService.getStats();

            if (stats.todayTotal == 0 && stats.allTimeTotal == 0) {
              return _buildEmptyState();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Streaks & Achievements Section
                  if (stats.currentStreak > 0 || stats.longestStreak > 0) ...[
                    _buildStreaksSection(stats),
                    const SizedBox(height: 24),
                  ],

                  // Today Header with Goal Progress
                  _buildTodayHeader(stats),
                  const SizedBox(height: 20),

                  // Daily Goal Progress (15 min default)
                  _buildDailyGoalCard(stats),
                  const SizedBox(height: 20),

                  // Weekly Chart
                  _buildWeeklyChart(stats),
                  const SizedBox(height: 24),

                  // Mode Breakdown
                  _buildModeBreakdown(stats),
                  const SizedBox(height: 24),

                  // Insights Section
                  _buildInsights(stats),
                  const SizedBox(height: 24),

                  // All Time Summary
                  _buildAllTimeSummary(stats),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar_circle,
              size: 100,
              color: CupertinoColors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 32),
            Text(
              'No Data Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a session to see\nyour statistics and progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.white.withOpacity(0.4),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksSection(stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            '🔥',
            '${stats.currentStreak}',
            'Day Streak',
            AppColors.antiStress,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStreakCard(
            '🏆',
            '${stats.longestStreak}',
            'Best Streak',
            AppColors.lightBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHeader(stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: CupertinoColors.white,
          ),
        ),
        if (stats.todaySessions > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${stats.todaySessions} session${stats.todaySessions > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDailyGoalCard(stats) {
    const dailyGoalSeconds = 900; // 15 minutes
    final progress = (stats.todayTotal / dailyGoalSeconds).clamp(0.0, 1.0);
    final isComplete = stats.todayTotal >= dailyGoalSeconds;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isComplete
              ? [AppColors.antiStress, AppColors.focusBounce]
              : [AppColors.primaryBlue, AppColors.lightBlue],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? AppColors.antiStress : AppColors.primaryBlue)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete ? 'Goal Completed! 🎉' : 'Daily Goal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: CupertinoColors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                CupertinoColors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stats.formatDuration(stats.todayTotal),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                ),
              ),
              Text(
                'of 15 min',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(stats) {
    final last7Days = stats.last7Days;
    final sortedDates = last7Days.keys.toList()..sort();
    
    int maxValue = 1;
    if (last7Days.values.isNotEmpty) {
      for (var value in last7Days.values) {
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last 7 Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              if (stats.weeklyProgress != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (stats.isImproving
                            ? AppColors.antiStress
                            : CupertinoColors.systemRed)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        stats.isImproving
                            ? CupertinoIcons.arrow_up
                            : CupertinoIcons.arrow_down,
                        size: 14,
                        color: stats.isImproving
                            ? AppColors.antiStress
                            : CupertinoColors.systemRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stats.weeklyProgress.abs().toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: stats.isImproving
                              ? AppColors.antiStress
                              : CupertinoColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedDates.map<Widget>((date) {
                final value = last7Days[date]!;
                final height = maxValue > 0 ? (value / maxValue) * 100 : 0.0;
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isToday
                                  ? [AppColors.antiStress, AppColors.lightBlue]
                                  : [
                                      AppColors.primaryBlue.withOpacity(0.6),
                                      AppColors.lightBlue.withOpacity(0.6),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDayLabel(date),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? CupertinoColors.white
                                : CupertinoColors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  Widget _buildModeBreakdown(stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 16),
        _StatCard(
          title: 'Anti-Stress',
          time: stats.formatDuration(stats.todayAntiStress),
          color: AppColors.antiStress,
          icon: CupertinoIcons.circle_fill,
          isFavorite: stats.favoriteMode == ModeType.antiStress,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Focus Bounce',
          time: stats.formatDuration(stats.todayFocusBounce),
          color: AppColors.focusBounce,
          icon: CupertinoIcons.sportscourt_fill,
          isFavorite: stats.favoriteMode == ModeType.focusBounce,
        ),
        const SizedBox(height: 12),
        _StatCard(
          title: 'Zen Sand',
          time: stats.formatDuration(stats.todayZenSand),
          color: AppColors.zenSand,
          icon: CupertinoIcons.paintbrush_fill,
          isFavorite: stats.favoriteMode == ModeType.zenSand,
        ),
      ],
    );
  }

  Widget _buildInsights(stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.lightbulb,
                color: AppColors.lightBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(
            'Average Session',
            stats.formatDuration(stats.averageSessionLength.toInt()),
            CupertinoIcons.time,
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            'Total Sessions',
            '${stats.totalSessions}',
            CupertinoIcons.layers_alt,
          ),
          if (stats.favoriteMode != null) ...[
            const SizedBox(height: 12),
            _buildInsightRow(
              'Favorite Mode',
              _getModeName(stats.favoriteMode!),
              CupertinoIcons.heart_fill,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: CupertinoColors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ],
    );
  }

  String _getModeName(ModeType mode) {
    switch (mode) {
      case ModeType.antiStress:
        return 'Anti-Stress';
      case ModeType.focusBounce:
        return 'Focus Bounce';
      case ModeType.zenSand:
        return 'Zen Sand';
    }
  }

  Widget _buildAllTimeSummary(stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'All Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stats.formatDuration(stats.allTimeTotal),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Time Relaxed',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;
  final bool isFavorite;

  const _StatCard({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
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
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.white,
                      ),
                    ),
                    if (isFavorite) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '❤️',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
