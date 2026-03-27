import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'src/parser.dart';
import 'src/renderer.dart';

export 'src/models.dart';
export 'src/parser.dart';
export 'src/renderer.dart';
export 'src/shapers/shaper.dart';
export 'src/shapers/bangla_shaper.dart';
export 'src/shapers/shaper_factory.dart';
export 'src/widgets/bangla_text.dart';

class HocrToPdf {
  /// Converts an hOCR string to a PDF document as [Uint8List].
  /// [font] is the base font for rendering.
  static Future<Uint8List> convert(
    String hocrString, {
    pw.Font? font,
    pw.Font? banglaFont,
    PdfColor backgroundColor = PdfColors.white,
  }) async {
    final pages = HocrParser.parse(hocrString);
    return await HocrPdfRenderer.render(
      pages, 
      font: font, 
      banglaFont: banglaFont,
      backgroundColor: backgroundColor,
    );
  }
}
