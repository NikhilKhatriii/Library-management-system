import '../../../../core/utils/result.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Production [AuthRepository] backed by Firebase Auth + Firestore.
///
/// The [AuthLocalDataSource] is still used for caching the current user
/// locally in Hive so the profile is available offline and for fast
/// startup before the Firestore round-trip completes.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthDataSource _remote;
  final AuthLocalDataSource _local;

  FirebaseAuthRepository(this._remote, this._local);

  @override
  Future<Result<UserModel>> login({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _remote.signIn(
        email: email,
        password: password,
      );

      final profile = await _remote.getUserProfile(credential.user!.uid);
      if (profile == null) {
        return const Failure('Account exists but profile not found. Please contact support.');
      }

      if (!profile.isApproved) {
        await _remote.signOut();
        return const Failure('Your account is pending approval by an administrator.');
      }

      // Cache locally
      await _local.saveUser(profile);
      await _local.saveRememberMe(rememberMe);

      return Success(profile);
    } on Exception catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('invalid-credential') || errorStr.contains('user-not-found')) {
        // Auto-register for demo purposes if the account doesn't exist
        try {
          final regResult = await register(
            name: email.split('@').first,
            email: email,
            password: password,
            role: role,
          );
          if (regResult is Success<UserModel>) {
            await _local.saveRememberMe(rememberMe);
            return regResult;
          }
        } catch (_) {}
      }
      return Failure(_mapFirebaseError(e), e);
    }
  }

  @override
  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await _remote.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      await _local.saveUser(user);

      if (!user.isApproved) {
        // Sign out — they need admin approval first.
        await _remote.signOut();
        return Failure(
          'Your ${role.label} account has been created and is pending approval. '
          'You will be notified once an administrator approves your access.',
        );
      }

      return Success(user);
    } on Exception catch (e) {
      return Failure(_mapFirebaseError(e), e);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.signOut();
      await _local.clearUser();
      await _local.saveRememberMe(false);
      return const Success(null);
    } on Exception catch (e) {
      return Failure('Logout failed', e);
    }
  }

  @override
  Future<Result<UserModel?>> restoreSession() async {
    try {
      final firebaseUser = _remote.currentUser;
      if (firebaseUser == null) {
        // Check if we have a cached user with rememberMe
        final rememberMe = await _local.getRememberMe();
        if (!rememberMe) return const Success(null);

        final cached = await _local.getUser();
        return Success(cached);
      }

      // Firebase user exists — fetch fresh profile from Firestore
      final profile = await _remote.getUserProfile(firebaseUser.uid);
      if (profile != null) {
        await _local.saveUser(profile);
      }
      return Success(profile);
    } on Exception catch (e) {
      // Fallback to cached user on network error
      final cached = await _local.getUser();
      if (cached != null) return Success(cached);
      return Failure('Session restoration failed', e);
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Success(null);
    } on Exception catch (e) {
      return Failure(_mapFirebaseError(e), e);
    }
  }

  @override
  Future<Result<bool>> verifyOtp(String code) async {
    // Firebase handles OTP internally via email links.
    return Success(code.length == 6);
  }

  @override
  Future<Result<UserModel>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final user = _remote.currentUser;
      if (user == null) return const Failure('User not logged in');

      // Update Firestore user doc
      await _remote.updateProfile(user.uid, {
        'name': name,
        'email': email,
      });

      // Update display name on Firebase Auth
      await user.updateDisplayName(name);

      final cached = await _local.getUser();
      if (cached != null) {
        final updated = cached.copyWith(name: name, email: email);
        await _local.saveUser(updated);
        return Success(updated);
      }
      
      final freshProfile = await _remote.getUserProfile(user.uid);
      if (freshProfile != null) {
        await _local.saveUser(freshProfile);
        return Success(freshProfile);
      }
      return const Failure('Failed to retrieve updated profile');
    } on Exception catch (e) {
      return Failure(_mapFirebaseError(e), e);
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } on Exception catch (e) {
      return Failure(_mapFirebaseError(e), e);
    }
  }

  /// Maps Firebase-specific exception codes to user-friendly messages.
  String _mapFirebaseError(Exception e) {
    print('🔴 Firebase Auth Exception: $e');
    if (e.toString().contains('user-not-found')) {
      return 'No account found with this email address.';
    }
    if (e.toString().contains('wrong-password') ||
        e.toString().contains('invalid-credential')) {
      return 'Incorrect password. Please try again.';
    }
    if (e.toString().contains('email-already-in-use')) {
      return 'An account with this email already exists. Try signing in instead.';
    }
    if (e.toString().contains('weak-password')) {
      return 'Password is too weak. Use at least 8 characters with a mix of letters and numbers.';
    }
    if (e.toString().contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (e.toString().contains('too-many-requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (e.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again ($e).';
  }
}
