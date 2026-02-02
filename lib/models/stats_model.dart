import 'session_model.dart';

class StatsModel {
  final int todayAntiStress;
  final int todayFocusBounce;
  final int todayZenSand;
  final int allTimeTotal;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int todaySessions;
  final ModeType? favoriteMode;
  final Map<DateTime, int> last7Days;
  final Map<DateTime, int> last30Days;
  final double averageSessionLength;
  final int weekTotal;
  final int lastWeekTotal;

  StatsModel({
    this.todayAntiStress = 0,
    this.todayFocusBounce = 0,
    this.todayZenSand = 0,
    this.allTimeTotal = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.todaySessions = 0,
    this.favoriteMode,
    this.last7Days = const {},
    this.last30Days = const {},
    this.averageSessionLength = 0.0,
    this.weekTotal = 0,
    this.lastWeekTotal = 0,
  });

  int get todayTotal => todayAntiStress + todayFocusBounce + todayZenSand;

  double get weeklyProgress {
    if (lastWeekTotal == 0) return 0.0;
    return ((weekTotal - lastWeekTotal) / lastWeekTotal * 100).clamp(-100, 500);
  }

  bool get isImproving => weeklyProgress > 0;

  String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  factory StatsModel.fromSessions(List<SessionModel> sessions) {
    int todayAntiStress = 0;
    int todayFocusBounce = 0;
    int todayZenSand = 0;
    int allTimeTotal = 0;
    int totalSessions = sessions.length;
    int todaySessions = 0;

    // Mode counters for favorite
    int antiStressCount = 0;
    int focusBounceCount = 0;
    int zenSandCount = 0;

    // Weekly stats
    int weekTotal = 0;
    int lastWeekTotal = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final twoWeeksAgo = today.subtract(const Duration(days: 14));

    // Maps for visualization
    Map<DateTime, int> last7Days = {};
    Map<DateTime, int> last30Days = {};

    // Initialize maps
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      last7Days[date] = 0;
    }
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      last30Days[date] = 0;
    }

    // Process sessions
    for (var session in sessions) {
      final seconds = session.duration.inSeconds;
      allTimeTotal += seconds;

      final sessionDate = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );

      // Count for favorite mode
      switch (session.mode) {
        case ModeType.antiStress:
          antiStressCount++;
          break;
        case ModeType.focusBounce:
          focusBounceCount++;
          break;
        case ModeType.zenSand:
          zenSandCount++;
          break;
      }

      // Today stats
      if (session.isToday()) {
        todaySessions++;
        switch (session.mode) {
          case ModeType.antiStress:
            todayAntiStress += seconds;
            break;
          case ModeType.focusBounce:
            todayFocusBounce += seconds;
            break;
          case ModeType.zenSand:
            todayZenSand += seconds;
            break;
        }
      }

      // Weekly stats
      if (sessionDate.isAfter(weekAgo) || sessionDate.isAtSameMomentAs(weekAgo)) {
        weekTotal += seconds;
      }
      if (sessionDate.isAfter(twoWeeksAgo) && sessionDate.isBefore(weekAgo)) {
        lastWeekTotal += seconds;
      }

      // Last 7 days map
      if (last7Days.containsKey(sessionDate)) {
        last7Days[sessionDate] = last7Days[sessionDate]! + seconds;
      }

      // Last 30 days map
      if (last30Days.containsKey(sessionDate)) {
        last30Days[sessionDate] = last30Days[sessionDate]! + seconds;
      }
    }

    // Calculate streaks
    final streaks = _calculateStreaks(sessions);

    // Determine favorite mode
    ModeType? favoriteMode;
    final maxCount = [antiStressCount, focusBounceCount, zenSandCount].reduce((a, b) => a > b ? a : b);
    if (maxCount > 0) {
      if (antiStressCount == maxCount) {
        favoriteMode = ModeType.antiStress;
      } else if (focusBounceCount == maxCount) {
        favoriteMode = ModeType.focusBounce;
      } else {
        favoriteMode = ModeType.zenSand;
      }
    }

    // Calculate average session length
    double averageSessionLength = totalSessions > 0 ? allTimeTotal / totalSessions : 0.0;

    return StatsModel(
      todayAntiStress: todayAntiStress,
      todayFocusBounce: todayFocusBounce,
      todayZenSand: todayZenSand,
      allTimeTotal: allTimeTotal,
      currentStreak: streaks['current']!,
      longestStreak: streaks['longest']!,
      totalSessions: totalSessions,
      todaySessions: todaySessions,
      favoriteMode: favoriteMode,
      last7Days: last7Days,
      last30Days: last30Days,
      averageSessionLength: averageSessionLength,
      weekTotal: weekTotal,
      lastWeekTotal: lastWeekTotal,
    );
  }

  static Map<String, int> _calculateStreaks(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Get unique days with sessions
    final uniqueDays = <DateTime>{};
    for (var session in sessions) {
      final day = DateTime(
        session.timestamp.year,
        session.timestamp.month,
        session.timestamp.day,
      );
      uniqueDays.add(day);
    }

    final sortedDays = uniqueDays.toList()..sort();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    // Calculate longest streak
    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Calculate current streak
    if (sortedDays.contains(todayDate)) {
      currentStreak = 1;
      DateTime checkDate = todayDate.subtract(const Duration(days: 1));
      while (sortedDays.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }
}
