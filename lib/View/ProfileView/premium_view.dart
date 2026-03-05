import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PremiumView extends StatelessWidget {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PaywallView(
          // Satın alma tamamlandığında
          onPurchaseCompleted:
              (CustomerInfo customerInfo, StoreTransaction storeTransaction) {
                // Entitlement adını 'Lingola Travel Pro' olarak kontrol ediyoruz
                if (customerInfo.entitlements.active.containsKey(
                  'Lingola Travel Pro',
                )) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                    "${LocaleKeys.purchase_success_title.tr()} ${LocaleKeys.purchase_success_subtitle.tr()}"
                      ),
                      backgroundColor: Color(0xFF4ECDC4),
                    ),
                  );
                  Navigator.pop(context, true);
                }
              },

          // Kullanıcı çarpıya basıp çıktığında
          onDismiss: () {
            Navigator.pop(context, false);
          },
        ),
      ),
    );
  }
}
