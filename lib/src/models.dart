enum HocrElementType { page, area, paragraph, line, word }

class HocrBbox {
  final int x1, y1, x2, y2;

  HocrBbox(this.x1, this.y1, this.x2, this.y2);

  double get width => (x2 - x1).toDouble();
  double get height => (y2 - y1).toDouble();

  static HocrBbox? fromTitle(String title) {
    final match = RegExp(r'bbox\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)').firstMatch(title);
    if (match != null) {
      return HocrBbox(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      );
    }
    return null;
  }
}

abstract class HocrElement {
  final String id;
  final HocrBbox bbox;

  HocrElement(this.id, this.bbox);
}

class HocrWord extends HocrElement {
  final String text;
  final String? language;
  
  HocrWord(String id, HocrBbox bbox, this.text, {this.language}) : super(id, bbox);
}

class HocrLine extends HocrElement {
  final List<HocrWord> words;
  HocrLine(String id, HocrBbox bbox, this.words) : super(id, bbox);
}

class HocrPage extends HocrElement {
  final List<HocrLine> lines;
  HocrPage(String id, HocrBbox bbox, this.lines) : super(id, bbox);
}
