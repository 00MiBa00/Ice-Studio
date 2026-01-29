import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/stats_service.dart';

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

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Today Section
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (stats.todayTotal > 0) ...[
                    // Total Time Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.lightBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stats.formatDuration(stats.todayTotal),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Per-Mode Stats
                    _StatCard(
                      title: 'Anti-Stress',
                      time: stats.formatDuration(stats.todayAntiStress),
                      color: AppColors.antiStress,
                      icon: CupertinoIcons.circle_fill,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Focus Bounce',
                      time: stats.formatDuration(stats.todayFocusBounce),
                      color: AppColors.focusBounce,
                      icon: CupertinoIcons.sportscourt_fill,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Zen Sand',
                      time: stats.formatDuration(stats.todayZenSand),
                      color: AppColors.zenSand,
                      icon: CupertinoIcons.paintbrush_fill,
                    ),
                    const SizedBox(height: 32),
                    // All Time Section
                    const Text(
                      'All Time',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.white,
                            ),
                          ),
                          Text(
                            stats.formatDuration(stats.allTimeTotal),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Empty State
                  if (stats.todayTotal == 0) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.chart_bar,
                            size: 80,
                            color: CupertinoColors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No activity yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start a session to see your stats',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                  ),
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
