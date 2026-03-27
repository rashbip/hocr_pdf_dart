import 'package:xml/xml.dart';
import 'models.dart';
import 'shaper.dart';

class HocrParser {
  static List<HocrPage> parse(String hocrContent) {
    // Standardize XML document with a single root
    final wrappedHocr = hocrContent.trim().startsWith('<html') || hocrContent.trim().startsWith('<?xml')
        ? hocrContent
        : '<root>$hocrContent</root>';
    final document = XmlDocument.parse(wrappedHocr);

    final pages = <HocrPage>[];
    for (var pageElement in document.findAllElements('div').where((e) => e.getAttribute('class') == 'ocr_page')) {
      final bbox = HocrBbox.fromTitle(pageElement.getAttribute('title') ?? '');
      if (bbox == null) continue;

      final lines = <HocrLine>[];
      for (var lineElement in pageElement.findAllElements('span').where((e) => e.getAttribute('class') == 'ocr_line')) {
        final lineBbox = HocrBbox.fromTitle(lineElement.getAttribute('title') ?? '');
        if (lineBbox == null) continue;

        final words = <HocrWord>[];
        for (var wordElement in lineElement.findAllElements('span').where((e) => e.getAttribute('class') == 'ocrx_word')) {
          final wordBbox = HocrBbox.fromTitle(wordElement.getAttribute('title') ?? '');
          if (wordBbox == null) continue;

          final rawText = wordElement.innerText.trim();
          if (rawText.isEmpty) continue;
          final text = HocrShaper.shape(rawText);

          words.add(HocrWord(wordElement.getAttribute('id') ?? '', wordBbox, text));
        }

        lines.add(HocrLine(lineElement.getAttribute('id') ?? '', lineBbox, words));
      }
      
      pages.add(HocrPage(pageElement.getAttribute('id') ?? '', bbox, lines));
    }
    return pages;
  }
}
