import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'src/parser.dart';
import 'src/renderer.dart';
import 'src/shapers/shaper.dart';

export 'src/models.dart';
export 'src/parser.dart';
export 'src/renderer.dart';
export 'src/shapers/shaper.dart';
export 'src/shapers/bangla_shaper.dart';
export 'src/shapers/shaper_factory.dart';

class HocrToPdf {
  /// Converts an hOCR string to a PDF document as [Uint8List].
  /// [font] is the base font for rendering.
  /// [shaper] can manually specify text shaping rules (e.g. [BanglaShaper]).
  /// [language] can be set to auto-detect a shaper (e.g. 'ben' for Bengali).
  static Future<Uint8List> convert(
    String hocrString, {
    pw.Font? font,
    HocrShaper? shaper,
    String? language,
    PdfColor backgroundColor = PdfColors.white,
  }) async {
    final pages = HocrParser.parse(hocrString, shaper: shaper, language: language);
    return await HocrPdfRenderer.render(pages, font: font, backgroundColor: backgroundColor);
  }
}
