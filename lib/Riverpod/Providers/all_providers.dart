import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global providers registry
/// All global state providers (user, auth, settings, etc.) are exported from here

export 'selected_language_provider.dart';

/// Navigator Key Provider (for global navigation)
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);
