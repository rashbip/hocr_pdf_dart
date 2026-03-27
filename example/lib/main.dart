import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hocr_pdf_dart/hocr_to_pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'bangla_pdf_test_screen.dart';
import 'hocr_bangla_test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Uint8List? _pdfData;
  bool _isLoading = false;
  Uint8List? _customFontBytes;
  String? _customFontName;

  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _pickFont() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _customFontBytes = result.files.single.bytes;
        _customFontName = result.files.single.name;
      });
    } else if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        _customFontBytes = bytes;
        _customFontName = result.files.single.name;
      });
    }
  }

  Future<void> _convertHocr() async {
    setState(() => _isLoading = true);
    try {
      final hocrContent = await rootBundle.loadString('assets/out.hocr');
      
      pw.Font? font;
      if (_customFontBytes != null) {
        font = pw.Font.ttf(_customFontBytes!.buffer.asByteData());
      } else {
        try {
          final fontData = await rootBundle.load('assets/Purno_Regular.ttf');
          font = pw.Font.ttf(fontData);
        } catch (_) {}
      }
      
      final pdfData = await HocrToPdf.convert(
        hocrContent, 
        font: font,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/output.pdf');
      await file.writeAsBytes(pdfData);
      await OpenFilex.open(file.path);

      setState(() => _pdfData = pdfData);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hOCR to PDF'),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 80, color: Colors.blue),
                    const SizedBox(height: 24),
                    Text(_customFontName != null ? 'Font: $_customFontName' : 'Using default font'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFont,
                      icon: const Icon(Icons.font_download),
                      label: const Text('Change Font'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _convertHocr,
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Convert hOCR to PDF'),
                    ),
                    if (_pdfData != null) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => Printing.sharePdf(bytes: _pdfData!, filename: 'output.pdf'),
                        icon: const Icon(Icons.share),
                        label: const Text('Share Result'),
                      ),
                    ],
                    const SizedBox(height: 48),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Official Plugin Test', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BanglaPdfTestScreen()),
                        );
                      },
                      icon: const Icon(Icons.verified),
                      label: const Text('Jump to Official Test Screen'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HocrBanglaTestScreen()),
                        );
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Jump to Hocr Bangla Test Screen'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
