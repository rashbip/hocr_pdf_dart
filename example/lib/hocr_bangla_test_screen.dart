import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hocr_pdf_dart/hocr_pdf_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class HocrBanglaTestScreen extends StatefulWidget {
  const HocrBanglaTestScreen({super.key});

  @override
  State<HocrBanglaTestScreen> createState() => _HocrBanglaTestScreenState();
}

class _HocrBanglaTestScreenState extends State<HocrBanglaTestScreen> {
  bool _isLoading = false;

  Future<void> _generateAndOpen() async {
    setState(() => _isLoading = true);
    try {
      // 1. Read hOCR data
      final hocrContent = await rootBundle.loadString('assets/out.hocr');
      
      // 2. Parse hOCR
      final pages = HocrParser.parse(hocrContent);
      
      // 3. Render to PDF
      // The renderer will automatically use BanglaShaper and Kalpurush font 
      // for words marked as 'ben' (Bengali).
      final pdfBytes = await HocrPdfRenderer.render(pages);
      
      // 4. Save and Open
      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/hocr_bangla_test.pdf");
      await file.writeAsBytes(pdfBytes);
      await OpenFilex.open(file.path);
      
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hocr Bengali PDF Test')),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Test Bengali PDF rendering from hOCR\n(Uses integrated BanglaShaper & Kalpurush)',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _generateAndOpen,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate & Open PDF'),
                ),
              ],
            ),
      ),
    );
  }
}
