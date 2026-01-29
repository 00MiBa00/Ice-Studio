import 'session_model.dart';

class StatsModel {
  final int todayAntiStress;
  final int todayFocusBounce;
  final int todayZenSand;
  final int allTimeTotal;

  StatsModel({
    this.todayAntiStress = 0,
    this.todayFocusBounce = 0,
    this.todayZenSand = 0,
    this.allTimeTotal = 0,
  });

  int get todayTotal => todayAntiStress + todayFocusBounce + todayZenSand;

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

    for (var session in sessions) {
      final seconds = session.duration.inSeconds;
      allTimeTotal += seconds;

      if (session.isToday()) {
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
    }

    return StatsModel(
      todayAntiStress: todayAntiStress,
      todayFocusBounce: todayFocusBounce,
      todayZenSand: todayZenSand,
      allTimeTotal: allTimeTotal,
    );
  }
}
