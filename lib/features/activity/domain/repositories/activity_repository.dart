import '../../../../core/utils/result.dart';
import '../models/transaction_model.dart';
import '../models/fine_model.dart';

abstract interface class ActivityRepository {
  Future<Result<List<TransactionModel>>> getTransactions({String? userId, String? status});
  Future<Result<TransactionModel>> issueBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  });
  Future<Result<void>> returnBook({required String transactionId});
  Future<Result<TransactionModel>> reserveBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  });
  Future<Result<List<FineModel>>> getFines({String? userId, String? status});
  Future<Result<void>> payFine({required String fineId});
}
