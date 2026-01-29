enum ModeType {
  antiStress,
  focusBounce,
  zenSand,
}

class SessionModel {
  final ModeType mode;
  final Duration duration;
  final DateTime timestamp;

  SessionModel({
    required this.mode,
    required this.duration,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.index,
      'duration': duration.inSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      mode: ModeType.values[json['mode'] as int],
      duration: Duration(seconds: json['duration'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  bool isToday() {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }
}
