import 'package:flutter_test/flutter_test.dart';
import 'package:hocr_pdf_dart/hocr_pdf_dart.dart';
import 'package:hocr_pdf_dart/hocr_pdf_dart_platform_interface.dart';
import 'package:hocr_pdf_dart/hocr_pdf_dart_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHocrPdfDartPlatform
    with MockPlatformInterfaceMixin
    implements HocrPdfDartPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HocrPdfDartPlatform initialPlatform = HocrPdfDartPlatform.instance;

  test('$MethodChannelHocrPdfDart is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHocrPdfDart>());
  });

  test('getPlatformVersion', () async {
    HocrPdfDart hocrPdfDartPlugin = HocrPdfDart();
    MockHocrPdfDartPlatform fakePlatform = MockHocrPdfDartPlatform();
    HocrPdfDartPlatform.instance = fakePlatform;

    expect(await hocrPdfDartPlugin.getPlatformVersion(), '42');
  });
}
