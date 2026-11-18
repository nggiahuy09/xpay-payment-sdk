import 'dart:collection';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remixicon/remixicon.dart';

import '../../base/define/constant/constant.dart';
import '../../di/di.dart';
import '../widgets/text/text_widgets.dart';

part 'snack_bar_controller.dart';
part 'snack_bar_view.dart';
part 'snack_bar_widget.dart';

final class XPSnackBarManager {
  const XPSnackBarManager._();

  /// [level] - The severity level of the message (error, warning, success, information). Each has different icon and color.
  ///
  /// [duration] - The duration the snack bar will stay visible before automatically hiding itself
  /// with animation. Default is 4 seconds, which is also the default duration of the framework.
  ///
  /// [indefiniteDuration] - Whether the snack bar should persist indefinitely. Setting this to true will also override the [duration].
  ///
  /// [closeOnContentTapped] - Whether tapping content should dismiss the snack bar **without** any animation.
  /// Only has effect if [onTapContent] is not null.
  ///
  /// [id] - The unique identifier of the snack bar. Ids can be used to remove a specific snack bar from the queue, or the current view.
  /// If not provided, a unique identifier will be generated based on timestamp.
  ///
  /// [bottomPadding] - The padding of the snack bar from the bottom of the view. [kToolbarHeight] will be used as default.
  static void show({
    required XPSnackBarMessageLevel level,
    XPSnackBarDuration? duration,
    String? id,
    required String title,
    String? body,
    int titleMaxLines = 2,
    int? bodyMaxLines,
    double? bottomPadding,
    bool indefiniteDuration = false,
    bool closeOnContentTapped = false,
    void Function()? onTapContent,
    // void Function()? onTapClose,
  }) {
    final snackBar = XPSnackBarItem(
      level: level,
      duration: indefiniteDuration ? XPSnackBarDuration.infinite.duration : (duration ?? XPSnackBarDuration.medium).duration,
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      titleMaxLines: titleMaxLines,
      bodyMaxLines: bodyMaxLines,
      bottomPadding: bottomPadding,
      closeOnContentTapped: closeOnContentTapped,
      onTapContent: onTapContent,
      // onTapClose: onTapClose,
    );
    getIt.get<SnackBarCubit>().add(snackBar);
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        padding: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 8.0),
        duration: indefiniteDuration ? const Duration(days: 365) : duration ?? const Duration(seconds: 4),
        content: _XPSnackBarWidget(
          key: key,
          level: level,
          title: title,
          body: body,
          titleMaxLines: titleMaxLines,
          bodyMaxLines: bodyMaxLines,
          closeOnContentTapped: closeOnContentTapped,
          onTapContent: onTapContent,
          onClosed: onClosed,
        ),
      ),
      snackBarAnimationStyle: AnimationStyle(
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      )
    );*/
  }

  static void closeCurrent() => getIt.get<SnackBarCubit>().closeCurrent();

  static void remove(String id) => getIt.get<SnackBarCubit>().remove(id);
}

final class XPSnackBarId {
  const XPSnackBarId._();

  static const String kSessionExpired = 'session_expired';
  static const String kNoConnection = 'no_connection';
}

enum XPSnackBarMessageLevel {
  error(Remix.error_warning_fill, XPColorIcon.negative, XPColorSurface.danger),
  warning(Remix.alert_fill, XPColorIcon.warning, XPColorSurface.warning),
  success(Remix.checkbox_circle_fill, XPColorIcon.positive, XPColorSurface.success),
  information(Remix.information_fill, XPColorIcon.subtle, XPColorSurface.secondary);

  const XPSnackBarMessageLevel(this.icon, this.iconColor, this.surfaceColor);

  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
}

/// The duration of the snack bar, in seconds.
///
/// [short, medium, long] - [2, 4, 6] secs
///
/// [infinite] - 365 days
enum XPSnackBarDuration {
  short(Duration(seconds: 2)),
  medium(Duration(seconds: 4)),
  long(Duration(seconds: 6)),
  infinite(Duration(days: 365));

  const XPSnackBarDuration(this.duration);

  final Duration duration;
}
