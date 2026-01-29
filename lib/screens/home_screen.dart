import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/first_launch_service.dart';
import '../services/sound_service.dart';
import '../widgets/mode_button.dart';
import '../widgets/subtle_hint.dart';
import 'anti_stress_screen.dart';
import 'focus_bounce_screen.dart';
import 'zen_sand_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _iconController;
  bool _showFirstLaunchModal = false;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation for background
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Icon breathing animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final firstLaunchService = FirstLaunchService();
    final isFirstLaunch = await firstLaunchService.isFirstLaunch();
    if (isFirstLaunch && mounted) {
      setState(() {
        _showFirstLaunchModal = true;
      });
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _startAntiStress() async {
    final firstLaunchService = FirstLaunchService();
    await firstLaunchService.setFirstLaunchComplete();
    if (mounted) {
      setState(() {
        _showFirstLaunchModal = false;
      });
      _navigateToMode(const AntiStressScreen());
    }
  }

  void _skipFirstLaunch() async {
    final firstLaunchService = FirstLaunchService();
    await firstLaunchService.setFirstLaunchComplete();
    if (mounted) {
      setState(() {
        _showFirstLaunchModal = false;
      });
    }
  }

  void _navigateToMode(Widget screen) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.darkBackground,
      child: Stack(
        children: [
          SafeArea(
            child: AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Header
                  const Text(
                    'Ice Studio',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Relax • Focus • Flow',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.white.withOpacity(0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Mode Buttons
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ModeButton(
                            title: 'Anti-Stress',
                            subtitle: 'Squeeze and release',
                            color: AppColors.antiStress,
                            icon: CupertinoIcons.circle_fill,
                            onTap: () => _navigateToMode(const AntiStressScreen()),
                          ),
                          const SizedBox(height: 20),
                          ModeButton(
                            title: 'Focus Bounce',
                            subtitle: 'Watch and concentrate',
                            color: AppColors.focusBounce,
                            icon: CupertinoIcons.sportscourt_fill,
                            onTap: () => _navigateToMode(const FocusBounceScreen()),
                          ),
                          const SizedBox(height: 20),
                          ModeButton(
                            title: 'Zen Sand',
                            subtitle: 'Draw and meditate',
                            color: AppColors.zenSand,
                            icon: CupertinoIcons.paintbrush_fill,
                            onTap: () => _navigateToMode(const ZenSandScreen()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated icons
                  AnimatedBuilder(
                    animation: _iconController,
                    builder: (context, child) {
                      final opacity = 0.2 + (_iconController.value * 0.3);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.circle_fill,
                            color: AppColors.antiStress.withOpacity(opacity),
                            size: 20,
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            CupertinoIcons.sportscourt_fill,
                            color: AppColors.focusBounce.withOpacity(opacity),
                            size: 20,
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            CupertinoIcons.paintbrush_fill,
                            color: AppColors.zenSand.withOpacity(opacity),
                            size: 20,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const SubtleHint(text: 'Choose a mode to begin'),
                  const SizedBox(height: 24),
                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: AppColors.surfaceDark,
                            onPressed: () => _navigateToMode(const StatisticsScreen()),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.chart_bar, size: 18),
                                SizedBox(width: 8),
                                Text('Statistics'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: AppColors.surfaceDark,
                            onPressed: () => _navigateToMode(const SettingsScreen()),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.settings, size: 18),
                                SizedBox(width: 8),
                                Text('Settings'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // First Launch Modal
          if (_showFirstLaunchModal)
            Container(
              color: CupertinoColors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Choose a mode to relax',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CupertinoButton(
                        color: AppColors.antiStress,
                        onPressed: _startAntiStress,
                        child: const Text('Start Anti-Stress'),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton(
                        onPressed: _skipFirstLaunch,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: CupertinoColors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
