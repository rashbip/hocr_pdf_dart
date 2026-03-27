import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hocr_pdf_dart/hocr_to_pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Selected Font: $_customFontName')),
      );
    } else if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        _customFontBytes = bytes;
        _customFontName = result.files.single.name;
      });
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Selected Font: $_customFontName')),
      );
    }
  }

  Future<void> _convertHocr() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hocrContent = await rootBundle.loadString('assets/out.hocr');
      
      pw.Font? font;
      if (_customFontBytes != null) {
        font = pw.Font.ttf(_customFontBytes!.buffer.asByteData());
        debugPrint('Using picked font: $_customFontName');
      } else {
        try {
          final fontData = await rootBundle.load('assets/Purno_Regular.ttf');
          font = pw.Font.ttf(fontData);
          debugPrint('Loaded Purno_Regular.ttf from assets');
        } catch (e) {
          debugPrint('Could not load default font: $e');
        }
      }
      
      final pdfData = await HocrToPdf.convert(
        hocrContent, 
        font: font,
        language: 'bangla',
      );

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/output.pdf');
      await file.writeAsBytes(pdfData);

      // Open in default PDF viewer
      await OpenFilex.open(file.path);

      setState(() {
        _pdfData = pdfData;
      });
    } catch (e) {
      debugPrint('Error converting: $e');
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('hOCR to PDF Converter'),
          centerTitle: true,
        ),
        body: Center(
          child: _isLoading
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generatng PDF...'),
                  ],
                )
              : _pdfData == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_outlined, size: 80, color: Colors.blueGrey),
                        const SizedBox(height: 24),
                        Text(
                          _customFontName != null 
                              ? 'Active Font: $_customFontName'
                              : 'Click the button below to convert\nhOCR to PDF and open it.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _pickFont,
                          icon: const Icon(Icons.font_download),
                          label: Text(_customFontName != null ? 'Change Custom Font' : 'Select Custom Font'),
                        ),
                        if (_customFontName != null)
                          TextButton(
                            onPressed: () => setState(() => _customFontBytes = _customFontName = null),
                            child: const Text('Reset to Default Font'),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                        const SizedBox(height: 24),
                        Text(
                          'PDF Generated & Opened! ${_customFontName != null ? '(using $_customFontName)' : ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'The PDF has been opened in your\nsystem\'s default PDF viewer.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _convertHocr,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate PDF'),
                        ),
                        if (_pdfData != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => Printing.sharePdf(bytes: _pdfData!, filename: 'output.pdf'),
                            icon: const Icon(Icons.share),
                            label: const Text('Share PDF'),
                          ),
                        ]
                      ],
                    ),
        ),
        floatingActionButton: _pdfData == null && !_isLoading
            ? FloatingActionButton.extended(
                onPressed: _convertHocr,
                label: const Text('Convert'),
                icon: const Icon(Icons.picture_as_pdf),
              )
            : null,
      ),
    );
  }
}
