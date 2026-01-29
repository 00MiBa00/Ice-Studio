import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService extends ChangeNotifier {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticsEnabledKey = 'haptics_enabled';
  
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _hapticsEnabled = prefs.getBool(_hapticsEnabledKey) ?? true;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, enabled);
    notifyListeners();
  }

  void playLightHaptic() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playMediumHaptic() {
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void playHeavyHaptic() {
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  // Placeholder for sound effects
  void playSquishSound() {
    if (_soundEnabled) {
      // In a real implementation, use audioplayers package
      // For now, just haptic feedback
      playLightHaptic();
    }
  }
}
