import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Core/Config/app_config.dart';
import 'Core/Config/environment_config.dart';
import 'Core/Routes/app_routes.dart';
import 'Core/Theme/my_colors.dart';
import 'Services/revenuecat_service.dart';
import 'Services/onesignal_service.dart';
import 'Riverpod/Providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Config (.env file)
  await EnvironmentConfig.init();

  // Initialize RevenueCat
  await RevenueCatService().init();

  // Initialize OneSignal (Push Notifications)
  await OneSignalService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the locale provider to rebuild when language changes
    final appLocale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(AppConfig.designWidth, AppConfig.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          // Set the current locale based on user preference
          locale: Locale(appLocale),
          // Define supported locales
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
            Locale('es'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('pt'),
            Locale('ru'),
            Locale('ja'),
            Locale('ko'),
            Locale('hi'),
          ],
          // Add localization delegates
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: MyColors.primary,
              primary: MyColors.primary,
              secondary: MyColors.secondary,
              surface: MyColors.surface,
              error: MyColors.error,
            ),
            scaffoldBackgroundColor: MyColors.background,
            textTheme: GoogleFonts.nunitoSansTextTheme(
              Theme.of(context).textTheme,
            ),
            useMaterial3: true,
          ),
          // Start from splash screen
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
