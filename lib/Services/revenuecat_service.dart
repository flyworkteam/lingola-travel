import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../Core/Config/app_config.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() {
    return _instance;
  }

  RevenueCatService._internal();

  /// Initialize RevenueCat SDK
  Future<void> init() async {
    if (!AppConfig.enableRevenueCat) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(AppConfig.revenueCatApiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(AppConfig.revenueCatApiKeyIOS);
    } else {
      return;
    }

    await Purchases.configure(configuration);
  }

  /// Displays the RevenueCat Paywall using RevenueCat UI
  Future<void> showPaywall() async {
    try {
      // Returns true if the paywall was presented and a purchase was made
      final paywallResult = await RevenueCatUI.presentPaywall();
      print('Paywall result: $paywallResult');
    } on PlatformException catch (e) {
      print('Error presenting paywall: $e');
    }
  }

  /// Displays the RevenueCat Paywall if the user does not have a specific entitlement
  Future<void> showPaywallIfNeeded(String entitlementId) async {
    try {
      await RevenueCatUI.presentPaywallIfNeeded(entitlementId);
    } on PlatformException catch (e) {
      print('Error presenting paywall if needed: $e');
    }
  }

  /// Restore purchases for the user
  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      print('Restored customer info: $customerInfo');
    } on PlatformException catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  /// Check if the user is currently premium
  Future<bool> isPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // Replace 'premium' with your entitlement ID configured in RevenueCat dashboard
      return customerInfo.entitlements.active.containsKey('premium');
    } on PlatformException catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }
}
