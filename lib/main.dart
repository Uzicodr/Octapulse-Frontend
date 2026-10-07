import 'package:flutter/material.dart';

import 'app.dart';
import 'data/services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Push stays off (and the app works as before) until the Firebase config files are added.
  await PushService.init();
  runApp(const App());
}
