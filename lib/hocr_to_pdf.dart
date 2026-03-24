import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'src/parser.dart';
import 'src/renderer.dart';

export 'src/models.dart';
export 'src/parser.dart';
export 'src/renderer.dart';

class HocrToPdf {
  /// Converts an hOCR string to a PDF document as [Uint8List].
  /// Provides better architecture and consistent line-based positioning.
  static Future<Uint8List> convert(
    String hocrString, {
    pw.Font? font,
    PdfColor backgroundColor = PdfColors.white,
  }) async {
    final pages = HocrParser.parse(hocrString);
    return await HocrPdfRenderer.render(pages, font: font, backgroundColor: backgroundColor);
  }
}
