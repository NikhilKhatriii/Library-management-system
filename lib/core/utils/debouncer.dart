import 'dart:async';

/// A reusable debounce utility.
///
/// Delays invocation of [action] until [duration] has elapsed since
/// the last call to [run]. If [run] is called again before the timer
/// expires, the previous pending action is cancelled.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  /// Schedule [action] to run after [duration]. Cancels any previous
  /// pending action.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending action.
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer and cancel any pending action.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
