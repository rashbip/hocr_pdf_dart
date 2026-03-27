import 'shaper.dart';
import 'bangla_shaper.dart';

class HocrShaperFactory {
  static HocrShaper? getShaperForLanguage(String? language) {
    if (language == null) return null;
    
    final lowerLang = language.toLowerCase();
    
    if (lowerLang.contains('ben') || lowerLang.contains('bengali') || lowerLang.contains('bangla')) {
      return BanglaShaper();
    }
    
    return null;
  }
}
