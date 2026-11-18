import 'package:flutter_bloc/flutter_bloc.dart';

extension EmitExtension<S> on Emitter<S> {
  /// Emits only if the handler is still active.
  void maybe(S state) {
    if (!isDone) call(state);
  }
}

extension BlocExtension<E, S> on Bloc<E, S> {
  /// Adds event only if bloc is still alive.
  void maybeAdd(E event) {
    if (!isClosed) add(event);
  }
}
