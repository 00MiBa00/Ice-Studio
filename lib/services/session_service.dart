import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

class SessionService extends ChangeNotifier {
  static const String _sessionsKey = 'sessions';
  static const int _minimumSessionSeconds = 10;
  
  List<SessionModel> _sessions = [];
  DateTime? _currentSessionStart;
  ModeType? _currentMode;

  List<SessionModel> get sessions => List.unmodifiable(_sessions);

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_sessionsKey);
    
    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      _sessions = decoded
          .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      print('📊 Loaded ${_sessions.length} sessions from storage');
      notifyListeners();
    } else {
      print('📊 No sessions found in storage');
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
    print('💾 Saved ${_sessions.length} sessions to storage');
  }

  void startSession(ModeType mode) {
    _currentSessionStart = DateTime.now();
    _currentMode = mode;
  }

  Future<void> endSession() async {
    if (_currentSessionStart == null || _currentMode == null) return;

    final duration = DateTime.now().difference(_currentSessionStart!);
    
    print('⏱️ Session ended: ${_currentMode?.toString()} - ${duration.inSeconds}s');
    
    // Only save sessions longer than minimum duration
    if (duration.inSeconds >= _minimumSessionSeconds) {
      final session = SessionModel(
        mode: _currentMode!,
        duration: duration,
        timestamp: _currentSessionStart!,
      );
      
      _sessions.add(session);
      await _saveSessions();
      notifyListeners();
      print('✅ Session saved successfully');
    } else {
      print('❌ Session too short (${duration.inSeconds}s < $_minimumSessionSeconds s)');
    }

    _currentSessionStart = null;
    _currentMode = null;
  }

  Future<void> addTestSessions() async {
    final now = DateTime.now();
    
    // Add test sessions for today
    _sessions.addAll([
      SessionModel(
        mode: ModeType.antiStress,
        duration: const Duration(minutes: 5),
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      SessionModel(
        mode: ModeType.focusBounce,
        duration: const Duration(minutes: 10),
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      SessionModel(
        mode: ModeType.zenSand,
        duration: const Duration(minutes: 8),
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
    
    // Add sessions for past days (for streak)
    for (int i = 1; i < 5; i++) {
      _sessions.add(
        SessionModel(
          mode: ModeType.antiStress,
          duration: const Duration(minutes: 15),
          timestamp: now.subtract(Duration(days: i)),
        ),
      );
    }
    
    await _saveSessions();
    notifyListeners();
    print('🧪 Added ${_sessions.length} test sessions');
  }

  Future<void> resetSessions() async {
    _sessions.clear();
    await _saveSessions();
    notifyListeners();
  }
}
