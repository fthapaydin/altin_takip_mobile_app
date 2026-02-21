import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altin_takip/core/di.dart';
import 'package:altin_takip/core/theme/app_theme.dart';
import 'package:altin_takip/core/services/onesignal_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:altin_takip/features/auth/presentation/auth_wrapper.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await initDependencies();

  // Global Navigator Key for deep linking
  final navigatorKey = GlobalKey<NavigatorState>();

  // Initialize OneSignal
  final oneSignal = sl<OneSignalService>();
  await oneSignal.initialize(navigatorKey);
  await oneSignal.requestPermission();

  runApp(ProviderScope(child: MyApp(navigatorKey: navigatorKey)));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Altın Cüzdan',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],
      locale: const Locale('tr', 'TR'),
      home: const AuthWrapper(),
    );
  }
}
