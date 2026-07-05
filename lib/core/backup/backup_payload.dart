import 'dart:convert';

import '../../features/bills/domain/models/bill_type.dart';
import '../../features/bills/domain/models/monthly_bill.dart';
import '../../features/expenses/domain/models/expense.dart';
import '../../features/people/domain/models/person.dart';
import 'backup_data_bundle.dart';

class BackupPayload {
  const BackupPayload({
    required this.appName,
    required this.backupVersion,
    required this.createdAt,
    required this.persons,
    required this.expenses,
    required this.billTypes,
    required this.monthlyBills,
  });

  static const appNameValue = 'EvApp';
  static const currentVersion = 1;

  final String appName;
  final int backupVersion;
  final DateTime createdAt;
  final List<Person> persons;
  final List<Expense> expenses;
  final List<BillType> billTypes;
  final List<MonthlyBill> monthlyBills;

  factory BackupPayload.create(BackupDataBundle bundle) {
    return BackupPayload(
      appName: appNameValue,
      backupVersion: currentVersion,
      createdAt: DateTime.now().toUtc(),
      persons: bundle.persons,
      expenses: bundle.expenses,
      billTypes: bundle.billTypes,
      monthlyBills: bundle.monthlyBills,
    );
  }

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    final appName = json['appName'];
    final backupVersion = json['backupVersion'];
    final createdAt = json['createdAt'];

    if (appName != appNameValue) {
      throw const FormatException('Gecersiz appName alani.');
    }

    if (backupVersion is! int) {
      throw const FormatException('backupVersion alani gerekli.');
    }

    if (backupVersion != currentVersion) {
      throw FormatException('Desteklenmeyen backupVersion: $backupVersion.');
    }

    if (createdAt is! String) {
      throw const FormatException('createdAt alani gerekli.');
    }

    final personsJson = _readRequiredList(json, 'persons');
    final expensesJson = _readRequiredList(json, 'expenses');
    final billTypesJson = _readRequiredList(json, 'billTypes');
    final monthlyBillsJson = _readRequiredList(json, 'monthlyBills');

    return BackupPayload(
      appName: appNameValue,
      backupVersion: backupVersion,
      createdAt: DateTime.parse(createdAt),
      persons: personsJson
          .map((item) => Person.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      expenses: expensesJson
          .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      billTypes: billTypesJson
          .map((item) => BillType.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      monthlyBills: monthlyBillsJson
          .map((item) => MonthlyBill.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'backupVersion': backupVersion,
      'createdAt': createdAt.toIso8601String(),
      'persons': persons.map((item) => item.toJson()).toList(),
      'expenses': expenses.map((item) => item.toJson()).toList(),
      'billTypes': billTypes.map((item) => item.toJson()).toList(),
      'monthlyBills': monthlyBills.map((item) => item.toJson()).toList(),
    };
  }

  String toEncodedJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  BackupDataBundle toBundle() {
    return BackupDataBundle(
      persons: persons,
      expenses: expenses,
      billTypes: billTypes,
      monthlyBills: monthlyBills,
    );
  }

  static List<dynamic> _readRequiredList(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];

    if (value is! List<dynamic>) {
      throw FormatException('$key alani liste olmali.');
    }

    return value;
  }
}
