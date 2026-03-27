import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../shapers/bangla_fixing_utils.dart';
import '../shapers/bangla_font_manager.dart';

class BanglaText extends pw.StatelessWidget {
  final String text;
  final pw.Font? font;
  final pw.Font? banglaFont;
  final double fontSize;
  final PdfColor color;
  final pw.FontWeight fontWeight;
  final pw.TextAlign? textAlign;

  BanglaText(
    this.text, {
    this.font,
    this.banglaFont,
    this.fontSize = 12,
    this.color = PdfColors.black,
    this.fontWeight = pw.FontWeight.normal,
    this.textAlign,
  });

  @override
  pw.Widget build(pw.Context context) {
    final spans = FixingUtils.getAutoLocalizedSpans(
      text: text,
      banglaFont: banglaFont ?? BanglaFontManager().defaultFont,
      generalFont: font,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );

    return pw.RichText(
      text: pw.TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}
