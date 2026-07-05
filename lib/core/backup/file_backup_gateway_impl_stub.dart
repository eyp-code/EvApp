import 'file_backup_gateway.dart';

class FileBackupGatewayImpl implements FileBackupGateway {
  const FileBackupGatewayImpl();

  @override
  Future<String> exportJson(String json) {
    throw UnsupportedError('Bu platformda backup disa aktarma desteklenmiyor.');
  }

  @override
  Future<String?> pickBackupJson() {
    throw UnsupportedError('Bu platformda backup ice aktarma desteklenmiyor.');
  }
}
