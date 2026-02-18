import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io';

/// Authentication Service
/// Handles social authentication (Google, Apple, Facebook)
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Sign in with Google
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in - don't show error
        return GoogleSignInResult(success: false, errorMessage: null);
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the ID token
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return GoogleSignInResult(
          success: false,
          errorMessage: 'Google token alınamadı',
        );
      }

      return GoogleSignInResult(
        success: true,
        idToken: idToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } catch (error) {
      print('Google Sign In Error: $error');

      // Check if user canceled the operation
      final errorString = error.toString();
      if (errorString.contains('sign_in_canceled') ||
          errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        // User canceled - don't show error message
        return GoogleSignInResult(success: false, errorMessage: null);
      }

      return GoogleSignInResult(
        success: false,
        errorMessage: 'Google girişi başarısız: $error',
      );
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Google Sign Out Error: $error');
    }
  }

  /// Check if Google Sign In is available
  bool get isGoogleSignInAvailable {
    return true; // Available on both iOS and Android
  }

  /// Sign in with Apple
  Future<AppleSignInResult> signInWithApple() async {
    try {
      // Check if Apple Sign In is available (iOS 13+, macOS 10.15+)
      if (!await SignInWithApple.isAvailable()) {
        return AppleSignInResult(
          success: false,
          errorMessage: 'Apple Sign In bu cihazda mevcut değil',
        );
      }

      // Request credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.lingola.travel.service',
          redirectUri: Uri.parse(
            'https://lingola-travel-api.com/auth/apple/callback',
          ),
        ),
      );

      // Get identity token
      final String? identityToken = credential.identityToken;

      if (identityToken == null) {
        return AppleSignInResult(
          success: false,
          errorMessage: 'Apple token alınamadı',
        );
      }

      // Build full name from given name and family name
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
      }

      return AppleSignInResult(
        success: true,
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        fullName: fullName,
        userIdentifier: credential.userIdentifier,
      );
    } catch (error) {
      print('Apple Sign In Error: $error');

      // Check if user canceled the operation
      final errorString = error.toString();
      if (errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        // User canceled - don't show error message
        return AppleSignInResult(success: false, errorMessage: null);
      }

      return AppleSignInResult(
        success: false,
        errorMessage: 'Apple girişi başarısız: $error',
      );
    }
  }

  /// Check if Apple Sign In is available
  Future<bool> get isAppleSignInAvailable async {
    return Platform.isIOS || Platform.isMacOS;
  }

  /// Sign in with Facebook
  Future<FacebookSignInResult> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // Check if user cancelled
      if (result.status == LoginStatus.cancelled) {
        // User cancelled - don't show error
        return FacebookSignInResult(success: false, errorMessage: null);
      }

      // Check if login failed
      if (result.status != LoginStatus.success) {
        return FacebookSignInResult(
          success: false,
          errorMessage: result.message ?? 'Facebook girişi başarısız',
        );
      }

      // Get access token
      final AccessToken? accessToken = result.accessToken;

      if (accessToken == null) {
        return FacebookSignInResult(
          success: false,
          errorMessage: 'Facebook token alınamadı',
        );
      }

      // Get user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );

      return FacebookSignInResult(
        success: true,
        accessToken: accessToken.tokenString,
        email: userData['email'],
        displayName: userData['name'],
        photoUrl: userData['picture']?['data']?['url'],
      );
    } catch (error) {
      print('Facebook Sign In Error: $error');

      // Check if user canceled the operation
      final errorString = error.toString();
      if (errorString.contains('canceled') ||
          errorString.contains('cancelled')) {
        // User canceled - don't show error message
        return FacebookSignInResult(success: false, errorMessage: null);
      }

      return FacebookSignInResult(
        success: false,
        errorMessage: 'Facebook girişi başarısız: $error',
      );
    }
  }

  /// Sign out from Facebook
  Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (error) {
      print('Facebook Sign Out Error: $error');
    }
  }

  /// Sign out from all providers
  Future<void> signOutAll() async {
    await signOutGoogle();
    await signOutFacebook();
    // Apple doesn't have a sign-out method
  }
}

/// Google Sign In Result
class GoogleSignInResult {
  final bool success;
  final String? idToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;

  GoogleSignInResult({
    required this.success,
    this.idToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
  });
}

/// Apple Sign In Result
class AppleSignInResult {
  final bool success;
  final String? identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;
  final String? userIdentifier;
  final String? errorMessage;

  AppleSignInResult({
    required this.success,
    this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
    this.userIdentifier,
    this.errorMessage,
  });
}

/// Facebook Sign In Result
class FacebookSignInResult {
  final bool success;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;

  FacebookSignInResult({
    required this.success,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
  });
}
