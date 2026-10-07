import 'dart:async';

class AccountUser {
  const AccountUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  /// The account id on the server; every synced row is stored under it.
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
}

enum SignInResult { signedIn, cancelled, failed }

/// Sign-in, kept behind an interface so the rest of the app and the tests
/// never touch Google or Supabase directly.
abstract class AuthService {
  /// False when the build has no backend settings.
  bool get isAvailable;

  AccountUser? get currentUser;

  /// Emits whenever the signed-in user changes (including sign-out as null).
  Stream<AccountUser?> get userChanges;

  Future<SignInResult> signInWithGoogle();

  Future<void> signOut();
}

/// Used when the build is not configured, and by default in tests.
class UnavailableAuthService implements AuthService {
  @override
  bool get isAvailable => false;
  @override
  AccountUser? get currentUser => null;
  @override
  Stream<AccountUser?> get userChanges => const Stream.empty();
  @override
  Future<SignInResult> signInWithGoogle() async => SignInResult.failed;
  @override
  Future<void> signOut() async {}
}

/// Scripted sign-in for tests.
class FakeAuthService implements AuthService {
  FakeAuthService({
    AccountUser? signedIn,
    this.nextResult = SignInResult.signedIn,
  }) : _user = signedIn;

  AccountUser? _user;
  final _controller = StreamController<AccountUser?>.broadcast();

  /// What the next sign-in attempt returns.
  SignInResult nextResult;

  /// The user a successful sign-in produces.
  AccountUser signInAs = const AccountUser(
    id: 'account-1',
    email: 'divya@example.com',
    displayName: 'Divya',
  );

  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  bool get isAvailable => true;
  @override
  AccountUser? get currentUser => _user;
  @override
  Stream<AccountUser?> get userChanges => _controller.stream;

  @override
  Future<SignInResult> signInWithGoogle() async {
    signInCalls++;
    if (nextResult == SignInResult.signedIn) {
      _user = signInAs;
      _controller.add(_user);
    }
    return nextResult;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _user = null;
    _controller.add(null);
  }
}
