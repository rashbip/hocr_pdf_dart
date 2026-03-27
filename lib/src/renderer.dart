import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'models.dart';
import 'shapers/shaper.dart';
import 'shapers/shaper_factory.dart';
import 'shapers/bangla_font_manager.dart';

class HocrPdfRenderer {
  static Future<Uint8List> render(List<HocrPage> pages, {pw.Font? font, pw.Font? banglaFont, PdfColor backgroundColor = PdfColors.white}) async {
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
                children: _buildWords(hocrPage, font, banglaFont),
              ),
            );
          },
        ),
      );
    }

    return await pdf.save();
  }

  static List<pw.Widget> _buildWords(HocrPage page, pw.Font? font, pw.Font? banglaFont) {
    final List<pw.Widget> children = [];
    final defaultBanglaFont = banglaFont ?? BanglaFontManager().defaultFont;
    final Map<String, HocrShaper?> shaperCache = {};

    for (var line in page.lines) {
      // Use line's vertical middle for stability
      final lineTop = (line.bbox.y1 - page.bbox.y1).toDouble();
      final lineHeight = line.bbox.height;

      for (var word in line.words) {
        final left = (word.bbox.x1 - page.bbox.x1).toDouble();
        final width = word.bbox.width;
        
        final hasBangla = word.text.contains(RegExp(r'[\u0980-\u09FF]'));
        
        final lang = word.language ?? '';
        if (!shaperCache.containsKey(lang)) {
          shaperCache[lang] = HocrShaperFactory.getShaperForLanguage(lang);
        }
        
        // If it's not tagged as Bangla but contains Bangla characters, use BanglaShaper
        var shaper = shaperCache[lang];
        if (shaper == null && hasBangla) {
          shaper = HocrShaperFactory.getShaperForLanguage('ben');
        }
        
        final shapedText = shaper != null ? shaper.shape(word.text) : word.text;
        
        // Use Bangla font if it contains Bangla characters or is tagged as such
        final isBangla = lang.toLowerCase().contains('ben') || 
                         lang.toLowerCase().contains('ban') ||
                         hasBangla;

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
                  shapedText,
                  style: pw.TextStyle(
                    font: isBangla ? defaultBanglaFont : font,
                    fontFallback: isBangla ? (font != null ? [font] : []) : [defaultBanglaFont],
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
