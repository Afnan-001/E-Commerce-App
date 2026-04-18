import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String?> saveOrderExportFile({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final baseDirectory = await getApplicationDocumentsDirectory();
  final folderName = mimeType == 'application/pdf' ? 'invoices' : 'exports';
  final directory = Directory(
    '${baseDirectory.path}${Platform.pathSeparator}petsworld${Platform.pathSeparator}$folderName',
  );
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final file = File('${directory.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
