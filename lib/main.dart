import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

import 'package:flutter/gestures.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wczytywanie kluczy API
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://wljdozodcnzslcqbrpwu.supabase.co',
    anonKey: 'sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t',
  );
  
  runApp(const NkodaApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class NkodaApp extends StatelessWidget {
  const NkodaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NKODA Europe',
      theme: AppTheme.darkTheme,
      scrollBehavior: AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}