import 'dart:convert';

import '../../features/bills/domain/models/bill_type.dart';
import '../../features/bills/domain/models/monthly_bill.dart';
import '../../features/expenses/domain/models/expense.dart';
import '../../features/people/domain/models/person.dart';
import 'backup_data_bundle.dart';
import 'backup_payload.dart';

abstract class BackupStore {
  Future<List<Person>> getAllPersons();

  Future<List<Expense>> getAllExpenses();

  Future<List<BillType>> getAllBillTypes();

  Future<List<MonthlyBill>> getAllMonthlyBills();

  Future<void> replaceAll(BackupDataBundle bundle);
}

class BackupService {
  const BackupService(this._store);

  final BackupStore _store;

  Future<String> exportBackupJson() async {
    final bundle = BackupDataBundle(
      persons: await _store.getAllPersons(),
      expenses: await _store.getAllExpenses(),
      billTypes: await _store.getAllBillTypes(),
      monthlyBills: await _store.getAllMonthlyBills(),
    );

    return BackupPayload.create(bundle).toEncodedJson();
  }

  Future<void> importBackupJson(String rawJson) async {
    final decoded = jsonDecode(rawJson);

    if (decoded is! Map) {
      throw const FormatException('Backup JSON nesne olmali.');
    }

    final payload = BackupPayload.fromJson(Map<String, dynamic>.from(decoded));
    await _store.replaceAll(payload.toBundle());
  }
}
