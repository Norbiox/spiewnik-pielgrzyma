import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:spiewnik_pielgrzyma/app/providers/hymn_pdf_storage.dart';
import 'package:spiewnik_pielgrzyma/models/hymn.dart';
import 'package:spiewnik_pielgrzyma/utils/encryption_service.dart';

const String hymnsPdfIdsMapFile = "assets/hymns_pdfs.csv";

abstract class HymnPdfProvider {
  String get loadingMessage;
  Future<Uint8List> getHymnPdfFile(Hymn hymn);
}

class NetworkHymnPdfProvider implements HymnPdfProvider {
  final String linkBase;

  NetworkHymnPdfProvider(this.linkBase);

  @override
  String get loadingMessage => "Trwa pobieranie nut...";

  String getHymnPdfUrl(Hymn hymn) {
    return linkBase + hymn.number.toUpperCase();
  }

  Future<Uint8List> fetchPdfFile(Hymn hymn) async {
    try {
      final response = await http.get(Uri.parse(getHymnPdfUrl(hymn)));

      if (response.statusCode != 200) {
        throw Exception("Failed to load hymn pdf");
      }

      return response.bodyBytes;
    } catch (networkError) {
      throw Exception(
          "Nie udało się pobrać nut. Upewnij się, że masz połączenie z internetem");
    }
  }

  @override
  Future<Uint8List> getHymnPdfFile(Hymn hymn) async {
    return await fetchPdfFile(hymn);
  }
}

class DecryptingNetworkHymnPdfProvider extends NetworkHymnPdfProvider {
  final EncryptionService encryptionService = GetIt.I.get<EncryptionService>();

  DecryptingNetworkHymnPdfProvider(super.linkBase);

  Future<Uint8List> decryptPdfFile(Uint8List pdf) async {
    return Uint8List.fromList(
        encryptionService.decryptData(String.fromCharCodes(pdf)).codeUnits);
  }

  @override
  Future<Uint8List> getHymnPdfFile(Hymn hymn) async {
    return await fetchPdfFile(hymn).then(decryptPdfFile);
  }
}

class DecryptingNetworkHymnPdfProviderWithStorage
    extends DecryptingNetworkHymnPdfProvider {
  final HymnPdfStorage hymnPdfStorage;

  DecryptingNetworkHymnPdfProviderWithStorage(
      this.hymnPdfStorage, String linkBase)
      : super(linkBase);

  @override
  Future<Uint8List> getHymnPdfFile(Hymn hymn) async {
    final pdfBytes = await hymnPdfStorage.getHymnPdfFile(hymn.number) ??
        await fetchPdfFile(hymn);
    await hymnPdfStorage.saveHymnPdfFile(hymn.number, pdfBytes);
    try {
      return await decryptPdfFile(pdfBytes);
    } catch (e) {
      debugPrint("Failed to decrypt hymn pdf: $e, will try to re-download");
      final pdfBytes = await fetchPdfFile(hymn);
      await hymnPdfStorage.saveHymnPdfFile(hymn.number, pdfBytes, force: true);
      return decryptPdfFile(pdfBytes);
    }
  }
}

Future<HymnPdfProvider> hymnPdfProviderFactory(String linkBase) async {
  if (kIsWeb) {
    return DecryptingNetworkHymnPdfProvider(linkBase);
  } else {
    final documentsPath = (await getApplicationDocumentsDirectory()).path;
    return DecryptingNetworkHymnPdfProviderWithStorage(
        DocumentsHymnPdfStorage(documentsPath), linkBase);
  }
}
