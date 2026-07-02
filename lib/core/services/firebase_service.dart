import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Singleton access to Firebase services used throughout the app.
///
/// Using this abstraction allows easy mocking during tests and
/// prevents tight coupling to Firebase imports across the codebase.
abstract final class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // ── Collection references ──────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> get booksCollection =>
      firestore.collection('books');

  static CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      firestore.collection('categories');

  static CollectionReference<Map<String, dynamic>> get authorsCollection =>
      firestore.collection('authors');

  static CollectionReference<Map<String, dynamic>> get publishersCollection =>
      firestore.collection('publishers');

  static CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      firestore.collection('transactions');

  static CollectionReference<Map<String, dynamic>> get reservationsCollection =>
      firestore.collection('reservations');

  static CollectionReference<Map<String, dynamic>> get finesCollection =>
      firestore.collection('fines');
}
