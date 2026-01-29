import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../services/sound_service.dart';
import '../painters/squish_ball_painter.dart';

class AntiStressScreen extends StatefulWidget {
  const AntiStressScreen({super.key});

  @override
  State<AntiStressScreen> createState() => _AntiStressScreenState();
}

class _AntiStressScreenState extends State<AntiStressScreen>
    with TickerProviderStateMixin {
  Offset _position = Offset.zero;
  double _scale = 1.0;
  double _squishX = 1.0;
  double _squishY = 1.0;
  double _rotation = 0.0;
  double _rotationVelocity = 0.0;
  int _squeezeCount = 0;
  bool _isInteracting = false;
  bool _showHint = true;

  late AnimationController _springController;
  late Animation<double> _springAnimation;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _hintController;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _springController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _springAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    );

    // Breathing animation for idle state
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Pulse animation for tap
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Hint fade out
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.startSession(ModeType.antiStress);

    // Hide hint after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showHint) {
        _hideHint();
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    _breathingController.dispose();
    _pulseController.dispose();
    _hintController.dispose();
    // End session tracking
    final sessionService = Provider.of<SessionService>(context, listen: false);
    sessionService.endSession();
    super.dispose();
  }

  void _hideHint() {
    _hintController.forward().then((_) {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  void _onTap(TapDownDetails details) {
    if (_showHint) _hideHint();
    
    setState(() {
      _squeezeCount++;
      _isInteracting = true;
    });

    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playMediumHaptic();

    // Pulse animation
    _pulseController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _isInteracting = false;
        });
      }
    });

    // Create particles
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      _particles.add(Particle(
        position: Offset(centerX, centerY),
        velocity: Offset(
          (50 + (i * 10)) * math.cos(angle),
          (50 + (i * 10)) * math.sin(angle),
        ),
        color: AppColors.antiStress,
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final ballSize = 200.0;

    // Clean up old particles
    _particles.removeWhere((p) => 
      DateTime.now().difference(p.createdAt).inMilliseconds > 1000
    );

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
          'Anti-Stress',
          style: TextStyle(color: CupertinoColors.white),
        ),
        trailing: _squeezeCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.antiStress.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_squeezeCount',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Main interaction area
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTap,
            onScaleStart: (details) {
              if (_showHint) _hideHint();
              setState(() {
                _springController.stop();
                _isInteracting = true;
              });
            },
            onScaleUpdate: (details) {
              setState(() {
                // Handle position (pan)
                _position += details.focalPointDelta;
                
                // Handle scale
                final newScale = details.scale.clamp(0.4, 2.5);
                if ((_scale - newScale).abs() > 0.1) {
                  _squeezeCount++;
                }
                _scale = newScale;
                _rotation += details.rotation * 0.5;
                
                // Pinch creates squish effect
                if (details.scale < 1.0) {
                  final squishFactor = (1.0 - details.scale).clamp(0.0, 0.6);
                  _squishX = 1.0 - squishFactor;
                  _squishY = 1.0 + squishFactor * 0.5;
                } else if (details.scale > 1.0) {
                  final expandFactor = (details.scale - 1.0).clamp(0.0, 0.4);
                  _squishX = 1.0 + expandFactor * 0.3;
                  _squishY = 1.0 - expandFactor * 0.2;
                }
                
                // Add rotation based on movement
                _rotationVelocity = details.focalPointDelta.dx * 0.01;
                _rotation += _rotationVelocity;
              });
            },
            onScaleEnd: (details) {
              setState(() {
                _isInteracting = false;
              });
              
              // Play haptic feedback
              final soundService = Provider.of<SoundService>(context, listen: false);
              soundService.playMediumHaptic();
              
              // Spring back to normal
              _springController.forward(from: 0).then((_) {
                if (mounted) {
                  setState(() {
                    _position = Offset.zero;
                    _scale = 1.0;
                    _squishX = 1.0;
                    _squishY = 1.0;
                    _rotationVelocity = 0.0;
                  });
                }
              });
            },
            child: SizedBox.expand(),
          ),
          // Particles
          ..._particles.map((particle) {
            final elapsed = DateTime.now().difference(particle.createdAt).inMilliseconds;
            final progress = elapsed / 1000.0;
            final opacity = (1.0 - progress).clamp(0.0, 1.0);
            final currentPos = particle.position + (particle.velocity * progress);
            
            return Positioned(
              left: currentPos.dx - 4,
              top: currentPos.dy - 4,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: particle.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
          // Ball
          Positioned(
            left: centerX + _position.dx - ballSize / 2,
            top: centerY + _position.dy - ballSize / 2,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _springAnimation,
                _breathingAnimation,
                _pulseAnimation,
              ]),
              builder: (context, child) {
                final animatedSquishX = 1.0 + (_squishX - 1.0) * (1.0 - _springAnimation.value);
                final animatedSquishY = 1.0 + (_squishY - 1.0) * (1.0 - _springAnimation.value);
                final animatedScale = 1.0 + (_scale - 1.0) * (1.0 - _springAnimation.value);
                
                // Apply breathing when not interacting
                final breathingScale = _isInteracting ? 1.0 : _breathingAnimation.value;
                final pulseScale = _pulseController.isAnimating 
                    ? (1.0 + (_pulseAnimation.value - 1.0) * (1.0 - _pulseController.value))
                    : 1.0;
                
                final finalScale = animatedScale * breathingScale * pulseScale;
                
                // Continuous slow rotation with inertia
                final displayRotation = _rotation + (_rotationVelocity * _springAnimation.value * 10);

                return Transform.scale(
                  scale: finalScale,
                  child: SizedBox(
                    width: ballSize,
                    height: ballSize,
                    child: CustomPaint(
                      painter: SquishBallPainter(
                        squishX: animatedSquishX,
                        squishY: animatedSquishY,
                        rotation: displayRotation,
                        baseColor: AppColors.antiStress,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Hint overlay
          if (_showHint)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_hintController),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.hand_thumbsup,
                      color: CupertinoColors.white.withOpacity(0.6),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap, drag, or pinch the ball',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Release your stress',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Particle class for effects
class Particle {
  final Offset position;
  final Offset velocity;
  final Color color;
  final DateTime createdAt;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.createdAt,
  });
}
