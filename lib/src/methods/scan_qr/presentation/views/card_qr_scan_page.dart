import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../base/define/constant/constant.dart';
import '../../../../base/localization/localization.dart';
import '../../../../core/domain/entities/xpay_qr_prefix.dart';
import '../../../../shared/helpers/helpers.dart';
import '../../../../shared/modal/modal_manager.dart';
import '../../../../shared/views/views.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/camera_permission_blocked_widget.dart';
import '../widgets/card_qr_invalid_widget.dart';
import '../widgets/qr_scanner_overlay_widget.dart';

final class CardQrScanPage extends StatefulWidget {
  const CardQrScanPage({super.key, required this.prefix, required this.title, required this.amount});

  final XpayQrPrefix prefix;
  final String title;
  final double amount;

  @override
  State<CardQrScanPage> createState() => _CardQrScanPageState();
}

final class _CardQrScanPageState extends State<CardQrScanPage> with SingleTickerProviderStateMixin {
  static const double _frameDimension = 248.0;
  static const double _frameVerticalOffset = -96.0;

  final MobileScannerController _scannerController = MobileScannerController(detectionSpeed: DetectionSpeed.normal);

  late final AnimationController _lineController;

  CameraPermissionStatus _permissionStatus = CameraPermissionStatus.checking;
  String? _rejectedRawValue;
  bool _hasHandledResult = false;
  bool _isShowingInvalidQr = false;

  Future<void> _initialize() async {
    final status = await XPHelperXpayOrScan.resolveCameraPermission(context);
    if (!mounted) return;

    setState(() => _permissionStatus = status);
  }

  void _handleOpenSettings() => openAppSettings();

  void _handleDetection(BarcodeCapture capture) {
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue != null && rawValue == _rejectedRawValue) return;

    _completeWith(rawValue);
  }

  Future<void> _handleUploadFromGallery() async {
    final imagePath = await XPHelperXpayOrScan.pickImageFromGallery();
    if (imagePath == null || !mounted) return;

    final rawValue = await XPHelperXpayOrScan.scanQrFromImage(_scannerController, imagePath);
    if (!mounted) return;

    _completeWith(rawValue);
  }

  void _completeWith(String? rawValue) {
    if (_hasHandledResult || _isShowingInvalidQr) return;
    if (rawValue == null || XpayQrPrefix.resolve(rawValue) != widget.prefix) {
      _showInvalidQr(rawValue);
      return;
    }

    _hasHandledResult = true;
    Navigator.of(context).pop(rawValue);
  }

  Future<void> _showInvalidQr(String? rawValue) async {
    _isShowingInvalidQr = true;
    _rejectedRawValue = rawValue;
    await XPModalManager.showBottomSheet<void>(context: context, autoWrap: true, showThumb: false, child: const CardQrInvalidWidget());
    _isShowingInvalidQr = false;
  }

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _lineController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = XPLocalization.instance.locale;
    final viewLocale = locale.payment.xpay;

    return Scaffold(
      backgroundColor: XPColorSurface.reverse,
      body: XPPlatformSafeAreaView(
        builder: (_) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    spacing: 16.0,
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: XPColorOverlay.theme15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Remix.close_line, size: 20.0, color: XPColorIcon.inversed),
                          ),
                        ),
                      ),
                      XPTextHighlightWidget.medium(widget.title, color: XPColorText.inversed),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (_permissionStatus) {
                    CameraPermissionStatus.blocked => CameraPermissionBlockedWidget(onOpenSettings: _handleOpenSettings),
                    CameraPermissionStatus.checking => const SizedBox.shrink(),
                    CameraPermissionStatus.granted => LayoutBuilder(
                      builder: (_, constraints) {
                        final frameTop = constraints.maxHeight / 2 + _frameVerticalOffset - _frameDimension / 2;
                        final belowFrameTop = constraints.maxHeight / 2 + _frameVerticalOffset + _frameDimension / 2 + 64.0;
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: MobileScanner(controller: _scannerController, onDetect: _handleDetection),
                            ),
                            Positioned.fill(
                              child: QrScannerOverlayWidget(animation: _lineController, frameDimension: _frameDimension, verticalOffset: _frameVerticalOffset),
                            ),
                            Positioned(
                              bottom: constraints.maxHeight - frameTop + 24.0,
                              left: 20.0,
                              right: 20.0,
                              child: Column(
                                spacing: 4.0,
                                children: [
                                  XPTextHeadingWidget.doubleExtraLarge(XPHelperCurrencyFormat.format(widget.amount), color: XPColorText.inversed),
                                  XPTextBodyWidget.small(viewLocale.amountToCollectLabel, color: XPColorText.inversed),
                                ],
                              ),
                            ),
                            Positioned(
                              top: belowFrameTop,
                              left: 20.0,
                              right: 20.0,
                              child: Column(
                                spacing: 16.0,
                                children: [
                                  XPTextBodyWidget.small(viewLocale.scanQrHint, color: XPColorText.inversed, textAlign: TextAlign.center),
                                  XPButtonFilled.large(
                                    label: viewLocale.uploadQrFromGallery,
                                    labelTextStyle: XPTextStyle.highlightSmall,
                                    leadingIcon: const Icon(Remix.image_line, size: 20.0, color: XPColorIcon.inversed),
                                    backgroundColor: XPColorOverlay.theme05,
                                    borderRadius: XPBorderRadius.pill,
                                    expanded: false,
                                    onPressed: _handleUploadFromGallery,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
