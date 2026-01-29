import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../services/session_service.dart';
import '../services/stats_service.dart';
import '../services/sound_service.dart';
import '../screens/home_screen.dart';

class IceStudio extends StatelessWidget {
  const IceStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SoundService()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (context) => SessionService()..loadSessions(),
        ),
        ChangeNotifierProxyProvider<SessionService, StatsService>(
          create: (context) => StatsService(
            Provider.of<SessionService>(context, listen: false),
          ),
          update: (context, sessionService, previous) =>
              previous ?? StatsService(sessionService),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
