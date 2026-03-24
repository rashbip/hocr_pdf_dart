import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hocr_pdf_dart_method_channel.dart';

abstract class HocrPdfDartPlatform extends PlatformInterface {
  /// Constructs a HocrPdfDartPlatform.
  HocrPdfDartPlatform() : super(token: _token);

  static final Object _token = Object();

  static HocrPdfDartPlatform _instance = MethodChannelHocrPdfDart();

  /// The default instance of [HocrPdfDartPlatform] to use.
  ///
  /// Defaults to [MethodChannelHocrPdfDart].
  static HocrPdfDartPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HocrPdfDartPlatform] when
  /// they register themselves.
  static set instance(HocrPdfDartPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
