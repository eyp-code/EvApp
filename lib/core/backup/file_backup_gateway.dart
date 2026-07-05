import 'file_backup_gateway_impl_stub.dart'
    if (dart.library.io) 'file_backup_gateway_impl_io.dart'
    as impl;

abstract class FileBackupGateway {
  factory FileBackupGateway() = impl.FileBackupGatewayImpl;

  Future<String> exportJson(String json);

  Future<String?> pickBackupJson();
}
