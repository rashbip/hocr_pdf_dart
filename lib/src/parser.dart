import 'package:xml/xml.dart';
import 'models.dart';
import 'shapers/shaper.dart';
import 'shapers/shaper_factory.dart';

class HocrParser {
  /// Parses hOCR content into a list of [HocrPage] objects.
  /// [shaper] can be provided manually, or [language] can be used to auto-select one.
  static List<HocrPage> parse(String hocrContent, {HocrShaper? shaper, String? language}) {
    // 1. Pre-process document
    final wrappedHocr = hocrContent.trim().startsWith('<html') || hocrContent.trim().startsWith('<?xml')
        ? hocrContent
        : '<root>$hocrContent</root>';
    final document = XmlDocument.parse(wrappedHocr);

    // 2. Select language shaper
    final activeShaper = shaper ?? HocrShaperFactory.getShaperForLanguage(language);

    final pages = <HocrPage>[];
    for (var pageElement in document.findAllElements('div').where((e) => e.getAttribute('class') == 'ocr_page')) {
      final bboxStr = pageElement.getAttribute('title') ?? '';
      final bbox = HocrBbox.fromTitle(bboxStr);
      if (bbox == null) continue;

      final pageLang = pageElement.getAttribute('lang') ?? language;
      final pageShaper = activeShaper ?? HocrShaperFactory.getShaperForLanguage(pageLang);

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

          // Apply language shaper if available
          final text = pageShaper != null ? pageShaper.shape(rawText) : rawText;

          words.add(HocrWord(wordElement.getAttribute('id') ?? '', wordBbox, text));
        }

        lines.add(HocrLine(lineElement.getAttribute('id') ?? '', lineBbox, words));
      }
      
      pages.add(HocrPage(pageElement.getAttribute('id') ?? '', bbox, lines));
    }
    return pages;
  }
}
