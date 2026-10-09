import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Google sign-in exchanged for a Supabase session (native flow: Google
/// hands back an ID token, and Supabase verifies it).
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client, {GoogleSignIn? google})
    : _google = google ?? GoogleSignIn.instance;

  final SupabaseClient _client;
  final GoogleSignIn _google;

  @override
  bool get isAvailable => true;

  @override
  AccountUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AccountUser?> get userChanges =>
      _client.auth.onAuthStateChange.map((e) => _map(e.session?.user));

  @override
  Future<SignInResult> signInWithGoogle() async {
    try {
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return SignInResult.failed;
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return SignInResult.signedIn;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return SignInResult.cancelled;
      }
      debugPrint('Google sign-in failed: ${e.code}');
      return SignInResult.failed;
    } on AuthException catch (e) {
      debugPrint('Supabase sign-in failed: ${e.message}');
      return SignInResult.failed;
    } catch (e) {
      debugPrint('Sign-in failed: $e');
      return SignInResult.failed;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {
      // Already signed out of Google; nothing to do.
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      await _client.rpc('delete_my_account');
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      return false;
    }
    // The account is gone, so ending the session may fail on the server.
    // Ending it on this phone is what matters.
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}
    return true;
  }

  AccountUser? _map(User? u) {
    if (u == null) return null;
    final meta = u.userMetadata ?? const {};
    return AccountUser(
      id: u.id,
      email: u.email,
      displayName: (meta['full_name'] ?? meta['name']) as String?,
      avatarUrl: (meta['avatar_url'] ?? meta['picture']) as String?,
    );
  }
}
