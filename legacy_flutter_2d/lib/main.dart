import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/storage_service.dart';
import 'ui/screens/tutorial_shell.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ProviderScope(child: WasteCorpApp()));
}

class WasteCorpApp extends StatelessWidget {
  const WasteCorpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Corp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const TutorialShell(),
    );
  }
}
