// ignore_for_file: use_super_parameters

part of 'loading_manager.dart';

class _LoadingOverlayDefaultWidget extends StatelessWidget {
  const _LoadingOverlayDefaultWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Material(
    color: XPColorOverlay.reverseTheme10,
    child: Center(child: CupertinoActivityIndicator()),
  );
}
