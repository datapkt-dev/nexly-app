// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'unit/auth_service.dart';
import 'firebase_options.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'models/locale.dart';
import 'models/theme_model.dart';
import 'modules/index/index.dart';
import 'modules/login/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase（跨平台）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 啟動前先檢查你自己的登入 Token（非 FCM）
  final auth = AuthService();
  final hasToken = await auth.getToken() != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel(ThemeData.light())),
        ChangeNotifierProvider(create: (_) => LocaleModel()),
        Provider.value(value: auth), // 之後想在 App 任一處取用 AuthService 可直接讀取
      ],
      child: MyApp(startOnIndex: hasToken),
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
