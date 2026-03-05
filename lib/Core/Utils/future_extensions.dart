import 'dart:async';

import 'package:flutter/material.dart';

extension FutureLoadingExtension<T> on Future<T> {
  Future<T> withLoading(BuildContext context) async {
    // 1. Loading Dialog'u göster
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false, // Kullanıcı ekrana basarak kapatamasın
        builder: (BuildContext context) {
          // Geri tuşuyla kapatılmasını da engellemek için WillPopScope (veya PopScope)
          return const PopScope(canPop: false, child: LoadingDialog());
        },
      ),
    );

    try {
      // 2. Asıl işlemi (Future) çalıştır ve sonucu bekle
      return await this;
    } catch (e) {
      // Hata olursa dışarı fırlat (Böylece try-catch ile yakalayabilirsin)
      rethrow;
    } finally {
      // 3. İşlem bitince (başarılı veya hatalı) Dialog'u kapat
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}

@immutable
final class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.brightnessOf(context) == Brightness.light;
    return Center(
      child: Container(
        width: 75,
        height: 75,
        // 1. Padding ekleyerek progress bar'ı küçültüyoruz
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: kElevationToShadow[4],
          color: isLightTheme ? Colors.white : Colors.black,
        ),
        // 2. Center ile sarmalayıp ortada kalmasını garantiliyoruz
        child: const Center(
          child: CircularProgressIndicator.adaptive(
            // 3. Android için çizgi kalınlığını biraz inceltiyoruz (varsayılan 4.0)
            strokeWidth: 3,
            // İstersen renk de verebilirsin (iOS için bu parametre çalışmaz)
            // valueColor: AlwaysStoppedAnimation<Color>(ColorName.colorPrimary),
          ),
        ),
      ),
    );
  }
}
