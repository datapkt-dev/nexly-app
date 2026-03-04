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
import 'modules/providers.dart';
import 'modules/index/controller/notification_controller.dart';

// 新增 FCM 與本地通知
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 背景處理必須是全局且頂層的函數
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 如果你要在背景處理時使用 Firebase，先初始化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('FCM background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 一定要最先
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 註冊背景 handler（必須在 initializeApp 後、runApp 前）
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 初始化 flutter_local_notifications（用於前台通知顯示）
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) {});

  // iOS/macOS: 請求通知權限
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // ✅ iOS 前台顯示推播（不設定的話前台收到推播不會顯示）
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 等待 APNs token（iOS 上不是立即可用，需要等系統回傳）
  String? apnsToken;
  for (int i = 0; i < 10; i++) {
    apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) break;
    print('⏳ 等待 APNs token... (${i + 1}/10)');
    await Future.delayed(const Duration(seconds: 2));
  }
  print('APNs Token: $apnsToken');
  if (apnsToken == null) {
    print('⚠️ APNs Token is null — 請確認：');
    print('  1. Xcode > Signing & Capabilities 有加 Push Notifications');
    print('  2. Apple Developer 帳號有啟用 Push Notifications');
    print('  3. Firebase Console 有上傳 APNs Auth Key (.p8)');
  }

  // 取得 FCM token（APNs token 就緒後才能取得）
  try {
    final token = await messaging.getToken();
    print('FCM Token: $token');
  } catch (e) {
    print('Get FCM token failed: $e');
  }

  // ✅ 建立共享的 ProviderContainer（讓 FCM listener 能更新 Riverpod state）
  final container = ProviderContainer();
  final notificationController = NotificationController();

  // 從 API 取得未讀數量並更新 provider
  Future<void> refreshUnreadCount() async {
    final count = await notificationController.getUnreadCount();
    container.read(unreadNotificationCountProvider.notifier).state = count;
  }

  // ✅ 訂閱前台接收
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 FCM foreground message received!');
    print('  title: ${message.notification?.title}');
    print('  body: ${message.notification?.body}');

    // 從 API 取得最新未讀數
    refreshUnreadCount();

    if (message.notification != null) {
      final notification = message.notification!;
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('default_channel', 'Default',
              importance: Importance.max, priority: Priority.high);
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iOSPlatformChannelSpecifics);
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  });

  // ✅ 使用者點擊推播打開 app（app 在背景時）
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📩 FCM onMessageOpenedApp: ${message.notification?.title}');
    refreshUnreadCount();
  });

  // ✅ Firebase 初始化完成後，才能用
  final auth = AuthService();
  final hasToken = await auth.getToken() != null;

  // ✅ 已登入的使用者，每次啟動 app 都註冊 FCM token 並取得未讀數
  if (hasToken) {
    auth.activateFcmToken();
    refreshUnreadCount();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
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
