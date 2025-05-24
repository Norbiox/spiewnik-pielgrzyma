import 'dart:io';
import 'dart:typed_data';

abstract class HymnPdfStorage {
  Future<Uint8List?> getHymnPdfFile(String hymnNumber);
  Future<void> saveHymnPdfFile(String hymnNumber, Uint8List pdfBytes,
      {bool force = false});
}

class DocumentsHymnPdfStorage implements HymnPdfStorage {
  final String documentsPath;

  DocumentsHymnPdfStorage(this.documentsPath);

  Future<File> _getFile(String hymnNumber) async {
    return File("$documentsPath/hymn_$hymnNumber.pdf");
  }

  @override
  Future<Uint8List?> getHymnPdfFile(String hymnNumber) async {
    final file = await _getFile(hymnNumber);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  @override
  Future<void> saveHymnPdfFile(String hymnNumber, Uint8List pdfBytes,
      {bool force = false}) async {
    final file = await _getFile(hymnNumber);
    if (force || !(await file.exists())) {
      await file.writeAsBytes(pdfBytes);
    }
  }
}
