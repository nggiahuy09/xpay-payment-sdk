part of 'snack_bar_manager.dart';

class XPSnackBarView extends StatefulWidget {
  const XPSnackBarView({super.key});

  @override
  State<XPSnackBarView> createState() => _XPSnackBarViewState();
}

class _XPSnackBarViewState extends State<XPSnackBarView> with SingleTickerProviderStateMixin {
  final _duration = const Duration(milliseconds: 350);

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  XPSnackBarItem? _current;

  Future<void> _restartAnimation(String? id, Duration? duration) async {
    _animationController.forward(from: 0);
    final delay = (duration ?? const Duration(seconds: 4)) - _duration;
    Future.delayed(delay).then((_) {
      if (mounted && id == _current?.id) _animationController.reverse();
    });
  }

  Future<void> _reverseAndClose() async {
    if (mounted) _animationController.reverse();
    getIt.get<SnackBarCubit>().closeCurrent();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _duration);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt.get<SnackBarCubit>(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: BlocListener<SnackBarCubit, XPSnackBarItem?>(
          listenWhen: (prev, next) => prev?.id != next?.id,
          listener: (_, state) {
            _current = state;
            _restartAnimation(state?.id, state?.duration);
          },
          child: BlocBuilder<SnackBarCubit, XPSnackBarItem?>(
            builder: (_, item) {
              final Widget view;
              if (item == null) {
                view = const SizedBox.shrink();
              } else {
                view = Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, item.bottomPadding ?? kToolbarHeight),
                  child: _XPSnackBarWidget(
                    key: ValueKey<String>(item.id),
                    level: item.level,
                    title: item.title,
                    body: item.body,
                    titleMaxLines: item.titleMaxLines,
                    bodyMaxLines: item.bodyMaxLines,
                    onTapContent: () {
                      if (item.onTapContent == null) return;
                      if (item.closeOnContentTapped) _reverseAndClose();
                      item.onTapContent?.call();
                    },
                    onTapClose: () => _reverseAndClose(),
                  ),
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(position: _slideAnimation, child: view),
              );
            },
          ),
        ),
      ),
    );
  }
}
