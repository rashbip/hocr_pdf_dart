import 'shaper.dart';
import 'bangla_unicode_mapper.dart';

class BanglaShaper extends HocrShaper {
  final bool useAnsiMapping;

  BanglaShaper({this.useAnsiMapping = true});

  @override
  String shape(String text) {
    if (text.isEmpty) return text;
    
    if (useAnsiMapping) {
      return BanglaUnicodeMapper.encodeANSI(text);
    }
    
    return text;
  }
}
