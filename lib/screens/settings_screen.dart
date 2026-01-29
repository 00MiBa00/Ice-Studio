import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/sound_service.dart';
import '../services/session_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showResetConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'This will permanently delete all session data and statistics. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              final sessionService = Provider.of<SessionService>(context, listen: false);
              await sessionService.resetSessions();
              if (context.mounted) {
                Navigator.of(context).pop();
                final soundService = Provider.of<SoundService>(context, listen: false);
                soundService.playMediumHaptic();
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
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
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
        ),
        middle: const Text(
          'Settings',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Consumer<SoundService>(
          builder: (context, soundService, child) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Audio & Haptics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SettingRow(
                        title: 'Sound',
                        subtitle: 'Play interaction sounds',
                        value: soundService.soundEnabled,
                        onChanged: (value) => soundService.setSoundEnabled(value),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.surfaceLight,
                      ),
                      _SettingRow(
                        title: 'Haptics',
                        subtitle: 'Vibration feedback',
                        value: soundService.hapticsEnabled,
                        onChanged: (value) => soundService.setHapticsEnabled(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () => _showResetConfirmation(context),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset Statistics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.destructiveRed,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Delete all session data',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          CupertinoIcons.trash,
                          color: CupertinoColors.destructiveRed,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Ice Studio',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
