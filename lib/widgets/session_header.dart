import 'package:flutter/cupertino.dart';

class SessionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const SessionHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: const Color(0xFF000000),
      border: null,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onBack,
        child: const Icon(
          CupertinoIcons.back,
          color: CupertinoColors.white,
        ),
      ),
      middle: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
    );
  }
}
