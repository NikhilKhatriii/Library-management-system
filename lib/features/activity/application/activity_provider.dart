import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../auth/application/auth_provider.dart';
import '../../auth/domain/models/user_role.dart';
import '../../books/application/books_provider.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/fine_model.dart';
import '../domain/repositories/activity_repository.dart';
import '../data/repositories/activity_repository_impl.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(ref.watch(bookRepositoryProvider));
});

class ActivityState {
  final List<TransactionModel> transactions;
  final List<FineModel> fines;
  final bool isLoading;
  final String? errorMessage;

  const ActivityState({
    this.transactions = const [],
    this.fines = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ActivityState copyWith({
    List<TransactionModel>? transactions,
    List<FineModel>? fines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ActivityState(
      transactions: transactions ?? this.transactions,
      fines: fines ?? this.fines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;
  final String? _userId;
  final bool _isAdminOrLibrarian;

  ActivityNotifier(this._repository, this._userId, this._isAdminOrLibrarian)
      : super(const ActivityState()) {
    loadActivity();
  }

  Future<void> loadActivity() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // If Admin/Librarian, load ALL transactions. Otherwise, filter by userId.
    final filterId = _isAdminOrLibrarian ? null : _userId;

    final txResult = await _repository.getTransactions(userId: filterId);
    final fineResult = await _repository.getFines(userId: filterId);

    if (txResult is Success<List<TransactionModel>> && fineResult is Success<List<FineModel>>) {
      state = state.copyWith(
        transactions: txResult.data,
        fines: fineResult.data,
        isLoading: false,
      );
    } else {
      final msg = txResult is Failure
          ? (txResult as Failure).message
          : (fineResult as Failure).message;
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
    }
  }

  Future<Result<TransactionModel>> issueBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.issueBook(
      userId: userId,
      userName: userName,
      bookId: bookId,
      bookTitle: bookTitle,
    );
    state = state.copyWith(isLoading: false);
    if (res is Success<TransactionModel>) {
      await loadActivity();
    }
    return res;
  }

  Future<Result<void>> returnBook({required String transactionId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.returnBook(transactionId: transactionId);
    state = state.copyWith(isLoading: false);
    if (res is Success<void>) {
      await loadActivity();
    }
    return res;
  }

  Future<Result<TransactionModel>> reserveBook({
    required String userId,
    required String userName,
    required String bookId,
    required String bookTitle,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.reserveBook(
      userId: userId,
      userName: userName,
      bookId: bookId,
      bookTitle: bookTitle,
    );
    state = state.copyWith(isLoading: false);
    if (res is Success<TransactionModel>) {
      await loadActivity();
    }
    return res;
  }

  Future<Result<void>> payFine({required String fineId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.payFine(fineId: fineId);
    state = state.copyWith(isLoading: false);
    if (res is Success<void>) {
      await loadActivity();
    }
    return res;
  }
}

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final user = ref.watch(authProvider).user;
  final repository = ref.watch(activityRepositoryProvider);
  final isLibrarian = user?.role == UserRole.librarian;
  return ActivityNotifier(repository, user?.id, isLibrarian);
});
