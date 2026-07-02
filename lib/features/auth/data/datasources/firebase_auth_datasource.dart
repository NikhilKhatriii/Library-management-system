import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_role.dart';

/// Datasource that communicates directly with Firebase Auth and Firestore
/// for all authentication and user-profile operations.
class FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseService.auth;

  /// Stream of auth-state changes (login, logout, token refresh).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in Firebase user, if any.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create a new account with email and password, then write a user
  /// document in Firestore's `users` collection.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(name);

    // Staff roles (admin / librarian) require manual approval.
    // NOTE: Temporarily disabled manual approval for demo/development purposes
    // so users can test the app without being locked out.
    // final needsApproval = role == UserRole.admin || role == UserRole.librarian;
    final needsApproval = false;

    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      isApproved: !needsApproval,
      membershipNumber: (role == UserRole.student || role == UserRole.teacher)
          ? 'LF-${1000 + email.hashCode.abs() % 9000}'
          : null,
    );

    // Persist user profile in Firestore.
    await FirebaseService.usersCollection
        .doc(credential.user!.uid)
        .set(user.toFirestore());

    return user;
  }

  /// Fetch the user profile from Firestore.
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await FirebaseService.usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Update user profile fields in Firestore.
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) async {
    await FirebaseService.usersCollection.doc(uid).update(fields);
  }

  /// Send a password-reset email via Firebase.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Change password for the currently signed-in user.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete the account permanently.
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await FirebaseService.usersCollection.doc(user.uid).delete();
    await user.delete();
  }
}
