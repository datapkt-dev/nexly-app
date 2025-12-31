// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'unit/auth_service.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'models/locale.dart';
import 'models/theme_model.dart';
import 'modules/index/index.dart';
import 'modules/login/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 一定要最先
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Firebase 初始化完成後，才能用
  final auth = AuthService();
  final hasToken = await auth.getToken() != null;

  runApp(
    ProviderScope(
      child: legacy.MultiProvider(
        providers: [
          legacy.ChangeNotifierProvider(
            create: (_) => ThemeModel(ThemeData.light()),
          ),
          legacy.ChangeNotifierProvider(
            create: (_) => LocaleModel(),
          ),
          legacy.Provider<AuthService>.value(
            value: auth,
          ),
        ],
        child: MyApp(startOnIndex: hasToken),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.startOnIndex});
  final bool startOnIndex;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleModel>().locale;

    return MaterialApp(
      title: 'Flutter Demo',
      // theme: context.watch<ThemeModel>().theme,
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ✅ 直接決定起始頁，無需 push/pop
      home: startOnIndex ? const Index() : const Login(),
    );
  }
}
