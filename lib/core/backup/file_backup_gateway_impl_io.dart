import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'file_backup_gateway.dart';

class FileBackupGatewayImpl implements FileBackupGateway {
  const FileBackupGatewayImpl();

  @override
  Future<String> exportJson(String json) async {
    final fileName = _buildFileName(prefix: 'evapp_backup');
    final bytes = Uint8List.fromList(utf8.encode(json));
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'EvApp yedegini kaydet',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
      lockParentWindow: true,
    );

    if (selectedPath == null) {
      throw FileSystemException('Kaydetme islemi iptal edildi.');
    }

    return selectedPath;
  }

  @override
  Future<String?> pickBackupJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    final files = result?.files;
    if (files == null || files.isEmpty) {
      return null;
    }

    final file = files.first;
    final bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes);
    }

    final path = file.path;
    if (path == null) {
      return null;
    }

    return File(path).readAsString(encoding: utf8);
  }

  String _buildFileName({required String prefix}) {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '${prefix}_${year}_${month}_${day}_${hour}_$minute.json';
  }
}
