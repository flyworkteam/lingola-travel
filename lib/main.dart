import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_travel/Core/Localization/localization_manager.dart';

import 'Core/Config/app_config.dart';
import 'Core/Config/environment_config.dart';
import 'Core/Routes/app_routes.dart';
import 'Core/Theme/my_colors.dart';
import 'Services/onesignal_service.dart';
import 'Services/revenuecat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LocalizationWrapper(
      child: Builder(
        builder: (context) {
          return ScreenUtilInit(
            designSize: const Size(
              AppConfig.designWidth,
              AppConfig.designHeight,
            ),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                navigatorKey: navigatorKey,
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
        },
      ),
    );
  }
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // Hiçbir animasyon uygulamadan direkt widget'ı döndürür
  }
}

@immutable
final class _LocalizationWrapper extends StatelessWidget {
  const _LocalizationWrapper({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: LocalizationManager.supportedLocales,
      path: LocalizationManager.path,
      fallbackLocale: LocalizationManager.defaultLocale,
      child: child,
    );
  }
}
