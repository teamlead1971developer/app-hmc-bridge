import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/branding.dart';
import 'core/router/app_router.dart';
import 'services/app_preferences_service.dart';
import 'services/auth_session_service.dart';
import 'services/notification_service.dart';
import 'widgets/glass_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSessionService.instance.init();
  await AppPreferencesService.instance.init();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AuthSessionService.instance.lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.dark,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(
          primary: kBrandColor,
          primaryForeground: Color(0xFFFFFFFF),
          ring: kBrandColor,
        ),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(
          primary: kBrandColor,
          primaryForeground: Color(0xFFFFFFFF),
          ring: kBrandColor,
        ),
      ),
      appBuilder: (context) {
        return MaterialApp.router(
          title: 'HMC Bridge',
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),
          routerConfig: appRouter,
          builder: (context, child) => ShadAppBuilder(
            child: ShadToaster(
              child: GlassBackground(child: child!),
            ),
          ),
        );
      },
    );
  }
}
