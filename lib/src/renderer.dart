import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'models.dart';

class HocrPdfRenderer {
  static Future<Uint8List> render(List<HocrPage> pages, {pw.Font? font, PdfColor backgroundColor = PdfColors.white}) async {
    final pdf = pw.Document();

    for (var hocrPage in pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(hocrPage.bbox.width, hocrPage.bbox.height),
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Container(
              color: backgroundColor,
              child: pw.Stack(
                children: _buildWords(hocrPage, font),
              ),
            );
          },
        ),
      );
    }

    return await pdf.save();
  }

  static List<pw.Widget> _buildWords(HocrPage page, pw.Font? font) {
    final List<pw.Widget> children = [];

    for (var line in page.lines) {
      // Use line's vertical middle for stability
      final lineTop = (line.bbox.y1 - page.bbox.y1).toDouble();
      final lineHeight = line.bbox.height;

      for (var word in line.words) {
        final left = (word.bbox.x1 - page.bbox.x1).toDouble();
        final width = word.bbox.width;

        children.add(
          pw.Positioned(
            left: left,
            top: lineTop,
            child: pw.SizedBox(
              width: width,
              height: lineHeight,
              child: pw.FittedBox(
                fit: pw.BoxFit.contain,
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  word.text,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: lineHeight * 0.8,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return children;
  }
}
