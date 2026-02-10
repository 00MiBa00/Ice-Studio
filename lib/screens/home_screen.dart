import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';
import '../services/first_launch_service.dart';
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

  Widget _buildFeatureRow(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.white.withOpacity(0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 48,
                        color: AppColors.antiStress,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to Ice Studio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your personal space for relaxation and focus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.white.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildFeatureRow(
                        CupertinoIcons.circle_fill,
                        'Anti-Stress',
                        'Squeeze the ball to release tension',
                        AppColors.antiStress,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(
                        CupertinoIcons.sportscourt_fill,
                        'Focus Bounce',
                        'Follow the ball to improve concentration',
                        AppColors.focusBounce,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(
                        CupertinoIcons.paintbrush_fill,
                        'Zen Sand',
                        'Draw patterns for meditation',
                        AppColors.zenSand,
                      ),
                      const SizedBox(height: 32),
                      CupertinoButton(
                        color: AppColors.antiStress,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _startAntiStress,
                        child: const Text(
                          'Try Anti-Stress Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoButton(
                        onPressed: _skipFirstLaunch,
                        child: Text(
                          'Explore on My Own',
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.white.withOpacity(0.5),
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
