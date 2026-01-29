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
      notifyListeners();
    }
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_sessionsKey, encoded);
  }

  void startSession(ModeType mode) {
    _currentSessionStart = DateTime.now();
    _currentMode = mode;
  }

  Future<void> endSession() async {
    if (_currentSessionStart == null || _currentMode == null) return;

    final duration = DateTime.now().difference(_currentSessionStart!);
    
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
    }

    _currentSessionStart = null;
    _currentMode = null;
  }

  Future<void> resetSessions() async {
    _sessions.clear();
    await _saveSessions();
    notifyListeners();
  }
}
