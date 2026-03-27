import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hocr_pdf_dart/hocr_to_pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

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
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _convertHocr() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load hOCR asset
      final hocrContent = await rootBundle.loadString('assets/out.hocr');
      
      pw.Font? font;
      try {
        final fontData = await rootBundle.load('assets/Purno_Regular.ttf');
        font = pw.Font.ttf(fontData);
        debugPrint('Loaded Purno_Regular.ttf from assets');
      } catch (e) {
        debugPrint('Could not load Purno_Regular.ttf from assets: $e');
      }
      
      final pdf = await HocrToPdf.convert(
        hocrContent, 
        font: font,
        language: 'bangla', // This will auto-select BanglaShaper
      );

      setState(() {
        _pdfData = pdf;
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
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('hOCR to PDF Converter'),
          actions: [
            if (_pdfData != null)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await Printing.sharePdf(bytes: _pdfData!, filename: 'output.pdf');
                },
              ),
          ],
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _pdfData == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description, size: 100, color: Colors.blueAccent),
                        const SizedBox(height: 20),
                        const Text(
                          'Ready to convert assets/out.hocr',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _convertHocr,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Convert to PDF'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: PdfPreview(
                            build: (format) => _pdfData!,
                            useActions: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _pdfData = null),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Convert Again'),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
