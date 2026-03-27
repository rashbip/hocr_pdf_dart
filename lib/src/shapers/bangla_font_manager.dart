import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import '../fonts/kalpurush_data.dart';

class BanglaFontManager {
  static final BanglaFontManager _instance = BanglaFontManager._internal();
  factory BanglaFontManager() => _instance;
  BanglaFontManager._internal();

  pw.Font? _defaultFont;

  pw.Font get defaultFont {
    if (_defaultFont == null) {
      final fontData = base64Decode(kalpurushBase64);
      _defaultFont = pw.Font.ttf(fontData.buffer.asByteData());
    }
    return _defaultFont!;
  }

  void setFont(pw.Font font) {
    _defaultFont = font;
  }
}
