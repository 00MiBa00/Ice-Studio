import 'package:flutter/foundation.dart';
import '../models/stats_model.dart';
import 'session_service.dart';

class StatsService extends ChangeNotifier {
  final SessionService _sessionService;
  
  StatsService(this._sessionService) {
    _sessionService.addListener(_onSessionsChanged);
  }

  void _onSessionsChanged() {
    notifyListeners();
  }

  StatsModel getStats() {
    return StatsModel.fromSessions(_sessionService.sessions);
  }

  @override
  void dispose() {
    _sessionService.removeListener(_onSessionsChanged);
    super.dispose();
  }
}
