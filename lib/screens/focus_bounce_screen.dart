import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../services/sound_service.dart';
import '../painters/bounce_painter.dart';

class FocusBounceScreen extends StatefulWidget {
  const FocusBounceScreen({super.key});

  @override
  State<FocusBounceScreen> createState() => _FocusBounceScreenState();
}

class _FocusBounceScreenState extends State<FocusBounceScreen> with SingleTickerProviderStateMixin {
  int? _selectedMinutes;
  bool _isSessionActive = false;
  bool _isSessionComplete = false;
  bool _showTimer = false;
  Timer? _bounceTimer;
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  
  Offset _ballPosition = const Offset(150, 150);
  Offset _ballVelocity = const Offset(2.5, 2.0);
  final double _ballRadius = 28;
  final double _gravity = 0.15;
  final double _elasticity = 0.92;
  
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Start session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.startSession(ModeType.focusBounce);
  }

  @override
  void dispose() {
    _bounceTimer?.cancel();
    _sessionTimer?.cancel();
    _breathingController.dispose();
    
    // End session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.endSession();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _isSessionActive = true;
      _isSessionComplete = false;
    });
    _startSession();
  }

  void _startSession() {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width - 80;
    final containerHeight = size.height - 250;

    // Physics-based bouncing animation
    _bounceTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Apply gravity
        _ballVelocity = Offset(_ballVelocity.dx, _ballVelocity.dy + _gravity);
        
        // Update position
        _ballPosition += _ballVelocity;

        // Elastic collisions with walls
        if (_ballPosition.dx <= 0 || _ballPosition.dx >= containerWidth - _ballRadius * 2) {
          _ballVelocity = Offset(-_ballVelocity.dx * _elasticity, _ballVelocity.dy);
          _ballPosition = Offset(
            _ballPosition.dx.clamp(0, containerWidth - _ballRadius * 2),
            _ballPosition.dy,
          );
        }

        if (_ballPosition.dy <= 0 || _ballPosition.dy >= containerHeight - _ballRadius * 2) {
          _ballVelocity = Offset(_ballVelocity.dx, -_ballVelocity.dy * _elasticity);
          _ballPosition = Offset(
            _ballPosition.dx,
            _ballPosition.dy.clamp(0, containerHeight - _ballRadius * 2),
          );
        }
      });
    });

    // Countdown timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endSession();
      }
    });
  }

  void _endSession() {
    _bounceTimer?.cancel();
    _sessionTimer?.cancel();
    
    // Haptic feedback
    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playMediumHaptic();
    
    setState(() {
      _isSessionActive = false;
      _isSessionComplete = true;
    });
  }

  void _toggleTimer() {
    setState(() {
      _showTimer = !_showTimer;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

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
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: const Text(
          'Focus Bounce',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: _isSessionComplete
            ? _buildCompletionScreen()
            : _isSessionActive
                ? _buildActiveSession()
                : _buildDurationSelection(),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Duration',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 48),
          _DurationButton(
            minutes: 5,
            isSelected: _selectedMinutes == 5,
            onTap: () => _selectDuration(5),
          ),
          const SizedBox(height: 16),
          _DurationButton(
            minutes: 10,
            isSelected: _selectedMinutes == 10,
            onTap: () => _selectDuration(10),
          ),
          const SizedBox(height: 16),
          _DurationButton(
            minutes: 15,
            isSelected: _selectedMinutes == 15,
            onTap: () => _selectDuration(15),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession() {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width - 80;
    final containerHeight = size.height - 250;

    return Column(
      children: [
        // Timer Display (tap to toggle)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleTimer,
          child: AnimatedOpacity(
            opacity: _showTimer ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ),
        // Bounce Container
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                // Subtle breathing effect on ball size
                final breathingRadius = _ballRadius * _breathingAnimation.value;
                
                return Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: BouncePainter(
                        ballPosition: _ballPosition + Offset(breathingRadius, breathingRadius),
                        ballRadius: breathingRadius,
                        ballColor: AppColors.focusBounce,
                        containerSize: Size(containerWidth, containerHeight),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.focusBounce.withOpacity(0.2),
            ),
            child: const Icon(
              CupertinoIcons.check_mark,
              size: 40,
              color: AppColors.focusBounce,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Session complete',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nice work slowing down',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 48),
          CupertinoButton(
            color: AppColors.focusBounce,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.focusBounce : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.focusBounce.withOpacity(isSelected ? 1.0 : 0.3),
            width: 2,
          ),
        ),
        child: Text(
          '$minutes minutes',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
