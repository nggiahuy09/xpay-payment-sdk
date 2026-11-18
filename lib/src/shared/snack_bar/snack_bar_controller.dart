part of 'snack_bar_manager.dart';

class SnackBarCubit extends Cubit<XPSnackBarItem?> {
  SnackBarCubit() : super(null);

  final _queue = Queue<XPSnackBarItem>();
  CancelableOperation? _iterator;
  bool _isShowing = false;

  void add(XPSnackBarItem item) {
    if (_queue.any((e) => e.id == item.id)) return;
    _queue.add(item);
    if (!_isShowing) _showNext();
  }

  Future<void> _showNext() async {
    if (_queue.isEmpty) {
      _isShowing = false;
      emit(null);
      return;
    }

    _isShowing = true;
    final item = _queue.removeFirst();
    emit(item);

    _iterator?.cancel();
    _iterator = CancelableOperation.fromFuture(Future.delayed(item.duration))..value.whenComplete(() => _showNext());
  }

  void closeCurrent() {
    _iterator?.cancel();
    _showNext();
  }

  void remove(String id) {
    _queue.removeWhere((e) => e.id == id);
    if (state?.id == id) closeCurrent();
  }

  void clear() {
    _queue.clear();
    emit(null);
    _isShowing = false;
  }
}

@immutable
final class XPSnackBarItem with Equatable {
  const XPSnackBarItem({
    required this.level,
    this.duration = const Duration(seconds: 4),
    required this.id,
    required this.title,
    this.body,
    this.titleMaxLines = 2,
    this.bodyMaxLines,
    this.bottomPadding,
    this.closeOnContentTapped = false,
    this.indefiniteDuration = false,
    this.onTapContent,
  });

  final XPSnackBarMessageLevel level;
  final Duration duration;
  final String id;
  final String title;
  final String? body;
  final int titleMaxLines;
  final int? bodyMaxLines;
  final double? bottomPadding;
  final bool closeOnContentTapped;
  final bool indefiniteDuration;
  final void Function()? onTapContent;

  @override
  List<Object?> get props => [id];
}
