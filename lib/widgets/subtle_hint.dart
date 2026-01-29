import 'package:flutter/cupertino.dart';

class SubtleHint extends StatefulWidget {
  final String text;

  const SubtleHint({
    super.key,
    required this.text,
  });

  @override
  State<SubtleHint> createState() => _SubtleHintState();
}

class _SubtleHintState extends State<SubtleHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}
