import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../services/sound_service.dart';
import '../painters/sand_painter.dart';

class ZenSandScreen extends StatefulWidget {
  const ZenSandScreen({super.key});

  @override
  State<ZenSandScreen> createState() => _ZenSandScreenState();
}

class _ZenSandScreenState extends State<ZenSandScreen> with SingleTickerProviderStateMixin {
  final List<SandTrailPoint> _trails = [];
  Offset _ballPosition = const Offset(200, 200);
  Offset _ballVelocity = const Offset(2, 1.5);
  bool _isManualControl = false;
  bool _isSlowMode = false;
  Timer? _autoMoveTimer;
  final double _ballRadius = 22;
  final Random _random = Random();

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _startAutoMovement();

    // Start session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.startSession(ModeType.zenSand);
  }

  @override
  void dispose() {
    _autoMoveTimer?.cancel();
    _fadeController.dispose();
    
    // End session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.endSession();
    super.dispose();
  }

  void _startAutoMovement() {
    _autoMoveTimer?.cancel();
    _autoMoveTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || _isManualControl) return;

      final size = MediaQuery.of(context).size;
      final maxX = size.width - _ballRadius * 2 - 80;
      final maxY = size.height - _ballRadius * 2 - 200;

      setState(() {
        // Smooth wandering with velocity-based movement
        final angle = (_random.nextDouble() - 0.5) * 0.3;
        final speed = _isSlowMode ? 0.5 : 1.5;
        
        _ballVelocity = Offset(
          (_ballVelocity.dx + cos(angle) * 0.5).clamp(-speed, speed),
          (_ballVelocity.dy + sin(angle) * 0.5).clamp(-speed, speed),
        );
        
        _ballPosition += _ballVelocity;

        // Bounce off edges smoothly
        if (_ballPosition.dx < 0 || _ballPosition.dx > maxX) {
          _ballVelocity = Offset(-_ballVelocity.dx * 0.8, _ballVelocity.dy);
          _ballPosition = Offset(
            _ballPosition.dx.clamp(0.0, maxX),
            _ballPosition.dy,
          );
        }

        if (_ballPosition.dy < 0 || _ballPosition.dy > maxY) {
          _ballVelocity = Offset(_ballVelocity.dx, -_ballVelocity.dy * 0.8);
          _ballPosition = Offset(
            _ballPosition.dx,
            _ballPosition.dy.clamp(0.0, maxY),
          );
        }

        // Add trail point with variable thickness
        final thickness = 2.5 + _random.nextDouble() * 1.5;
        _trails.add(SandTrailPoint(
          position: Offset(
            _ballPosition.dx + _ballRadius,
            _ballPosition.dy + _ballRadius,
          ),
          timestamp: DateTime.now().millisecondsSinceEpoch,
          thickness: thickness,
        ));

        // Limit trails
        if (_trails.length > 600) {
          _trails.removeRange(0, _trails.length - 600);
        }
      });
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isManualControl = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    final maxX = size.width - _ballRadius * 2 - 80;
    final maxY = size.height - _ballRadius * 2 - 200;

    setState(() {
      // Smooth acceleration based on swipe direction
      _ballVelocity = Offset(
        (details.delta.dx * 0.3).clamp(-4.0, 4.0),
        (details.delta.dy * 0.3).clamp(-4.0, 4.0),
      );
      
      var newX = _ballPosition.dx + details.delta.dx;
      var newY = _ballPosition.dy + details.delta.dy;

      newX = newX.clamp(0.0, maxX);
      newY = newY.clamp(0.0, maxY);

      _ballPosition = Offset(newX, newY);
      
      // Add trail point
      _trails.add(SandTrailPoint(
        position: Offset(
          _ballPosition.dx + _ballRadius,
          _ballPosition.dy + _ballRadius,
        ),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        thickness: 3.0,
      ));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isManualControl = false;
    });
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isSlowMode = true;
    });
    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playLightHaptic();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isSlowMode = false;
    });
  }

  void _clearTrails() {
    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playMediumHaptic();
    
    _fadeController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _trails.clear();
        });
        _fadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width - 80;
    final containerHeight = size.height - 200;

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
          'Zen Sand',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _clearTrails,
          child: const Text(
            'Clear',
            style: TextStyle(color: AppColors.zenSand),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - (_fadeController.value * 0.5),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: GestureDetector(
                    onLongPressStart: _onLongPressStart,
                    onLongPressEnd: _onLongPressEnd,
                    child: CustomPaint(
                    size: Size(containerWidth, containerHeight),
                    painter: SandPainter(
                      trails: _trails,
                      ballPosition: _ballPosition + Offset(_ballRadius, _ballRadius),
                      ballRadius: _ballRadius,
                      trailColor: AppColors.zenSand,
                      ballColor: AppColors.zenSand,
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
