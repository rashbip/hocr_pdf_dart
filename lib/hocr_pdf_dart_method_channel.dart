import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hocr_pdf_dart_platform_interface.dart';

/// An implementation of [HocrPdfDartPlatform] that uses method channels.
class MethodChannelHocrPdfDart extends HocrPdfDartPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hocr_pdf_dart');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
