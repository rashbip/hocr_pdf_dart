import 'dart:typed_data';
import 'package:xml/xml.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HocrToPdf {
  /// Converts an hOCR string to a PDF document as [Uint8List].
  /// [font] allows passing a [pw.Font] directly.
  /// [backgroundColor] defaults to white.
  static Future<Uint8List> convert(
    String hocrString, {
    pw.Font? font,
    PdfColor backgroundColor = PdfColors.white,
  }) async {
    final pdf = pw.Document();
    
    // In pure Dart, we avoid making assumptions about the filesystem.
    // The font should be provided as a [pw.Font] object.
    final activeFont = font;

    // Wrap the string to make it valid XML if it has multiple pages as root elements
    final wrappedHocr = hocrString.trim().startsWith('<html') || hocrString.trim().startsWith('<?xml')
        ? hocrString
        : '<root>$hocrString</root>';
    final document = XmlDocument.parse(wrappedHocr);

    final pages = document.findAllElements('div').where((e) => e.getAttribute('class') == 'ocr_page');

    for (var pageElement in pages) {
      final title = pageElement.getAttribute('title') ?? '';
      final pageBbox = _parseBbox(title);
      if (pageBbox == null) continue;

      final pageWidth = (pageBbox[2] - pageBbox[0]).toDouble();
      final pageHeight = (pageBbox[3] - pageBbox[1]).toDouble();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, pageHeight),
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            final words = pageElement.findAllElements('span').where((e) => e.getAttribute('class') == 'ocrx_word');

            return pw.Container(
              color: backgroundColor,
              child: pw.Stack(
                children: words.map((wordElement) {
                  final wordTitle = wordElement.getAttribute('title') ?? '';
                  final wordBbox = _parseBbox(wordTitle);
                  if (wordBbox == null) return pw.SizedBox();

                  final wordText = wordElement.innerText.trim();
                  if (wordText.isEmpty) return pw.SizedBox();

                  final left = (wordBbox[0] - pageBbox[0]).toDouble();
                  final top = (wordBbox[1] - pageBbox[1]).toDouble();
                  final width = (wordBbox[2] - wordBbox[0]).toDouble();
                  final height = (wordBbox[3] - wordBbox[1]).toDouble();

                  return pw.Positioned(
                    left: left,
                    top: top,
                    child: pw.SizedBox(
                      width: width,
                      height: height,
                      child: pw.FittedBox(
                        fit: pw.BoxFit.contain,
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          wordText,
                          style: pw.TextStyle(
                            font: activeFont,
                            fontSize: height * 0.8,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      );
    }

    return await pdf.save();
  }

  static List<int>? _parseBbox(String title) {
    final match = RegExp(r'bbox\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)').firstMatch(title);
    if (match != null) {
      return [
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      ];
    }
    return null;
  }
}
