import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/core/theme/app_theme.dart';
import 'ui/features/notifications/push_binding.dart';
import 'ui/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final _router = createRouter();
  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: PushBinding(
        router: _router,
        messengerKey: _messengerKey,
        child: MaterialApp.router(
          title: 'OctaPulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          scaffoldMessengerKey: _messengerKey,
          routerConfig: _router,
        ),
      ),
    );
  }
}
