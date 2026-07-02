import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/fine_model.dart';
import '../../domain/repositories/activity_repository.dart';

class FirestoreActivityRepository implements ActivityRepository {
  @override
  Future<Result<List<TransactionModel>>> getTransactions({String? userId, String? status}) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseService.transactionsCollection;
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel(
          id: doc.id,
          bookId: data['bookId'] as String? ?? '',
          bookTitle: data['bookTitle'] as String? ?? '',
          userId: data['userId'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          issueDate: (data['issueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
          status: data['status'] as String? ?? 'active',
        );
      }).toList();
      
      // Sort in-memory to avoid needing index in firestore right away
      list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
      return Success(list);
    } catch (e) {
      return Failure('Failed to load transactions from Firestore', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<TransactionModel>> issueBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  }) async {
    try {
      // 1. Get book and check availability
      final bookDoc = await FirebaseService.booksCollection.doc(bookId).get();
      if (!bookDoc.exists) return const Failure('Book not found');
      
      final bookData = bookDoc.data()!;
      final availableCopies = bookData['availableCopies'] as int? ?? 0;
      final totalCopies = bookData['totalCopies'] as int? ?? 0;
      if (availableCopies <= 0) {
        return const Failure('No copies available for checkout');
      }

      // 2. Add Transaction
      final txData = {
        'bookId': bookId,
        'bookTitle': bookTitle,
        'userId': userId,
        'userName': userName,
        'issueDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'status': 'active',
      };

      final txRef = await FirebaseService.transactionsCollection.add(txData);

      // 3. Update Book Copies
      await FirebaseService.booksCollection.doc(bookId).update({
        'availableCopies': (availableCopies - 1).clamp(0, totalCopies),
      });

      final tx = TransactionModel(
        id: txRef.id,
        bookId: bookId,
        bookTitle: bookTitle,
        userId: userId,
        userName: userName,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'active',
      );

      return Success(tx);
    } catch (e) {
      return Failure('Failed to issue book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> returnBook({required String transactionId}) async {
    try {
      final txDoc = await FirebaseService.transactionsCollection.doc(transactionId).get();
      if (!txDoc.exists) return const Failure('Transaction not found');
      
      final txData = txDoc.data()!;
      final bookId = txData['bookId'] as String;
      final status = txData['status'] as String;
      final dueDate = (txData['dueDate'] as Timestamp).toDate();

      if (status != 'active' && status != 'overdue') {
        return const Failure('Book is already returned');
      }

      final now = DateTime.now();

      // 1. Update Transaction
      await FirebaseService.transactionsCollection.doc(transactionId).update({
        'returnDate': FieldValue.serverTimestamp(),
        'status': 'returned',
      });

      // 2. Update Book Copies
      final bookDoc = await FirebaseService.booksCollection.doc(bookId).get();
      if (bookDoc.exists) {
        final bookData = bookDoc.data()!;
        final availableCopies = bookData['availableCopies'] as int? ?? 0;
        final totalCopies = bookData['totalCopies'] as int? ?? 0;
        await FirebaseService.booksCollection.doc(bookId).update({
          'availableCopies': (availableCopies + 1).clamp(0, totalCopies),
        });
      }

      // 3. Calculate Fine if overdue
      if (now.isAfter(dueDate)) {
        final daysOverdue = now.difference(dueDate).inDays;
        if (daysOverdue > 0) {
          final fineAmount = daysOverdue * 2.0;
          await FirebaseService.finesCollection.add({
            'userId': txData['userId'],
            'userName': txData['userName'],
            'bookTitle': txData['bookTitle'],
            'amount': fineAmount,
            'status': 'unpaid',
            'createdAt': FieldValue.serverTimestamp(),
            'transactionId': transactionId,
          });
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure('Failed to return book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<TransactionModel>> reserveBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  }) async {
    try {
      final txData = {
        'bookId': bookId,
        'bookTitle': bookTitle,
        'userId': userId,
        'userName': userName,
        'issueDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'status': 'reserved',
      };

      final txRef = await FirebaseService.transactionsCollection.add(txData);

      final tx = TransactionModel(
        id: txRef.id,
        bookId: bookId,
        bookTitle: bookTitle,
        userId: userId,
        userName: userName,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'reserved',
      );

      return Success(tx);
    } catch (e) {
      return Failure('Failed to reserve book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<FineModel>>> getFines({String? userId, String? status}) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseService.finesCollection;
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return FineModel(
          id: doc.id,
          userId: data['userId'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          bookTitle: data['bookTitle'] as String? ?? '',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          status: data['status'] as String? ?? 'unpaid',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Success(list);
    } catch (e) {
      return Failure('Failed to load fines from Firestore', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> payFine({required String fineId}) async {
    try {
      await FirebaseService.finesCollection.doc(fineId).update({
        'status': 'paid',
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to pay fine', e is Exception ? e : Exception(e.toString()));
    }
  }
}
