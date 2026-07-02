import 'package:hive/hive.dart';
import '../../../../core/utils/result.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../../books/domain/models/book.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/fine_model.dart';
import '../../domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final BookRepository _bookRepository;
  static const String _txBoxName = 'activity_transactions';
  static const String _fineBoxName = 'activity_fines';

  ActivityRepositoryImpl(this._bookRepository);

  Future<Box<Map>> _getTxBox() async {
    return await Hive.openBox<Map>(_txBoxName);
  }

  Future<Box<Map>> _getFineBox() async {
    return await Hive.openBox<Map>(_fineBoxName);
  }

  @override
  Future<Result<List<TransactionModel>>> getTransactions({String? userId, String? status}) async {
    try {
      final box = await _getTxBox();
      final list = box.values
          .map((e) => TransactionModel.fromJson(e))
          .where((tx) {
            if (userId != null && tx.userId != userId) return false;
            if (status != null && tx.status != status) return false;
            return true;
          })
          .toList();
      // Sort by issueDate descending
      list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
      return Success(list);
    } catch (e) {
      return Failure('Failed to load transactions', e is Exception ? e : Exception(e.toString()));
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
      final bookResult = await _bookRepository.getBookById(bookId);
      if (bookResult is Failure<dynamic>) {
        return Failure('Book not found: ${(bookResult as Failure).message}');
      }
      final book = (bookResult as Success).data;
      if (book.availableCopies <= 0) {
        return const Failure('No copies available for checkout');
      }

      // 2. Check if already checked out
      final txBox = await _getTxBox();
      final alreadyIssued = txBox.values
          .map((e) => TransactionModel.fromJson(e))
          .any((tx) => tx.userId == userId && tx.bookId == bookId && tx.status == 'active');
      if (alreadyIssued) {
        return const Failure('You have already checked out this book');
      }

      // 3. Create Transaction
      final txId = DateTime.now().millisecondsSinceEpoch.toString();
      final tx = TransactionModel(
        id: txId,
        bookId: bookId,
        bookTitle: bookTitle,
        userId: userId,
        userName: userName,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'active',
      );

      // Save Transaction
      await txBox.put(txId, tx.toJson());

      // 4. Update book copies
      final updatedBook = book.copyWith(
        availableCopies: book.availableCopies - 1,
      );
      await _bookRepository.updateBook(updatedBook);

      return Success(tx);
    } catch (e) {
      return Failure('Failed to issue book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> returnBook({required String transactionId}) async {
    try {
      final txBox = await _getTxBox();
      final txData = txBox.get(transactionId);
      if (txData == null) {
        return const Failure('Transaction not found');
      }

      final tx = TransactionModel.fromJson(txData);
      if (tx.status != 'active' && tx.status != 'overdue') {
        return const Failure('Book is already returned');
      }

      final now = DateTime.now();

      // 1. Update Transaction
      final updatedTx = tx.copyWith(
        returnDate: now,
        status: 'returned',
      );
      await txBox.put(transactionId, updatedTx.toJson());

      // 2. Update Book Copies
      final bookResult = await _bookRepository.getBookById(tx.bookId);
      if (bookResult is Success<Book>) {
        final book = bookResult.data;
        final updatedBook = book.copyWith(
          availableCopies: (book.availableCopies + 1).clamp(0, book.totalCopies),
        );
        await _bookRepository.updateBook(updatedBook);
      }

      // 3. Calculate Fine if overdue
      if (now.isAfter(tx.dueDate)) {
        final daysOverdue = now.difference(tx.dueDate).inDays;
        if (daysOverdue > 0) {
          final fineAmount = daysOverdue * 2.0; // $2.00 per day
          final fineBox = await _getFineBox();
          final fineId = 'fine_$transactionId';
          final fine = FineModel(
            id: fineId,
            userId: tx.userId,
            userName: tx.userName,
            bookTitle: tx.bookTitle,
            amount: fineAmount,
            status: 'unpaid',
            createdAt: now,
          );
          await fineBox.put(fineId, fine.toJson());
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
      final bookResult = await _bookRepository.getBookById(bookId);
      if (bookResult is Failure<dynamic>) {
        return Failure('Book not found: ${(bookResult as Failure).message}');
      }
      // Verify book exists

      // Create Reservation
      final txBox = await _getTxBox();
      final txId = DateTime.now().millisecondsSinceEpoch.toString();
      final tx = TransactionModel(
        id: txId,
        bookId: bookId,
        bookTitle: bookTitle,
        userId: userId,
        userName: userName,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'reserved',
      );

      await txBox.put(txId, tx.toJson());
      return Success(tx);
    } catch (e) {
      return Failure('Failed to reserve book', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<FineModel>>> getFines({String? userId, String? status}) async {
    try {
      final box = await _getFineBox();
      final list = box.values
          .map((e) => FineModel.fromJson(e))
          .where((fine) {
            if (userId != null && fine.userId != userId) return false;
            if (status != null && fine.status != status) return false;
            return true;
          })
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Success(list);
    } catch (e) {
      return Failure('Failed to load fines', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> payFine({required String fineId}) async {
    try {
      final box = await _getFineBox();
      final fineData = box.get(fineId);
      if (fineData == null) {
        return const Failure('Fine not found');
      }

      final fine = FineModel.fromJson(fineData);
      final updated = fine.copyWith(status: 'paid');
      await box.put(fineId, updated.toJson());
      return const Success(null);
    } catch (e) {
      return Failure('Failed to pay fine', e is Exception ? e : Exception(e.toString()));
    }
  }
}
