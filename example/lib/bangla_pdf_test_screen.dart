import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hocr_pdf_dart/hocr_pdf_dart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class BanglaPdfTestScreen extends StatefulWidget {
  const BanglaPdfTestScreen({super.key});

  @override
  State<BanglaPdfTestScreen> createState() => _BanglaPdfTestScreenState();
}

class _BanglaPdfTestScreenState extends State<BanglaPdfTestScreen> {
  bool _isLoading = false;

  Future<void> _generateAndOpen() async {
    setState(() => _isLoading = true);
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: "Official Bangla PDF Package Test"),
              pw.SizedBox(height: 20),
              // Use the plugin's integrated BanglaText widget
              BanglaText(
                'This is a mixed text: আমি বাংলাদেশ ভালোবাসি। I love Bangladesh.',
                fontSize: 20,
              ),
              pw.SizedBox(height: 20),
              BanglaText(
                'Juktakkhor Test: ক্ষ্মজ্ঞ জ্ঞ ক্ক ত্র শ্র স্তু সঁচাঁ',
                fontSize: 24,
              ),
            ],
          ),
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/bangla_pdf_test.pdf");
      await file.writeAsBytes(await pdf.save());
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bangla PDF Official Test')),
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_outlined, size: 80, color: Colors.indigo),
                const SizedBox(height: 20),
                const Text(
                  'Test pure bangla_pdf package functionality.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _generateAndOpen,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate & Open Proof PDF'),
                ),
              ],
            ),
      ),
    );
  }
}
