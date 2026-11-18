import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../permission/permission_manager.dart';

final class XPHelperXpayOrScan {
  const XPHelperXpayOrScan._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Requests camera permission and resolves the matching scan status.
  static Future<CameraPermissionStatus> resolveCameraPermission(BuildContext context) async {
    final granted = await XPPermissionManager.requestCameraPermission(context);
    return granted ? CameraPermissionStatus.granted : CameraPermissionStatus.blocked;
  }

  /// Picks an image from the gallery, returning its path, or null when the picker is dismissed.
  static Future<String?> pickImageFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  /// Analyzes the image at [imagePath], returning the first decoded QR raw value.
  static Future<String?> scanQrFromImage(MobileScannerController scannerController, String imagePath) async {
    final capture = await scannerController.analyzeImage(imagePath);
    return capture?.barcodes.firstOrNull?.rawValue;
  }
}

enum CameraPermissionStatus { checking, granted, blocked }
