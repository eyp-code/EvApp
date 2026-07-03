import 'package:hive/hive.dart';

import '../../domain/models/bill_type.dart';
import '../../domain/models/monthly_bill.dart';

class BillLocalDataSource {
  const BillLocalDataSource({
    required Box<Map> billTypesBox,
    required Box<Map> monthlyBillsBox,
  }) : _billTypesBox = billTypesBox,
       _monthlyBillsBox = monthlyBillsBox;

  final Box<Map> _billTypesBox;
  final Box<Map> _monthlyBillsBox;

  Future<List<BillType>> getBillTypes() async {
    final billTypes = _billTypesBox.values
        .map((value) => BillType.fromJson(Map<String, dynamic>.from(value)))
        .where((billType) => !billType.isDeleted)
        .toList();

    billTypes.sort((first, second) => first.name.compareTo(second.name));

    return billTypes;
  }

  Future<void> saveBillType(BillType billType) async {
    await _billTypesBox.put(billType.id, billType.toJson());
  }

  Future<BillType?> getBillTypeById(String id) async {
    final value = _billTypesBox.get(id);

    if (value == null) {
      return null;
    }

    return BillType.fromJson(Map<String, dynamic>.from(value));
  }

  Future<List<MonthlyBill>> getMonthlyBills() async {
    final monthlyBills = _monthlyBillsBox.values
        .map((value) => MonthlyBill.fromJson(Map<String, dynamic>.from(value)))
        .where((monthlyBill) => !monthlyBill.isDeleted)
        .toList();

    _sortMonthlyBills(monthlyBills);

    return monthlyBills;
  }

  Future<List<MonthlyBill>> getAllMonthlyBills() async {
    final monthlyBills = _monthlyBillsBox.values
        .map((value) => MonthlyBill.fromJson(Map<String, dynamic>.from(value)))
        .toList();

    _sortMonthlyBills(monthlyBills);

    return monthlyBills;
  }

  void _sortMonthlyBills(List<MonthlyBill> monthlyBills) {
    monthlyBills.sort((first, second) {
      final yearComparison = second.year.compareTo(first.year);

      if (yearComparison != 0) {
        return yearComparison;
      }

      return second.month.compareTo(first.month);
    });
  }

  Future<MonthlyBill?> getMonthlyBillById(String id) async {
    final value = _monthlyBillsBox.get(id);

    if (value == null) {
      return null;
    }

    return MonthlyBill.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> saveMonthlyBill(MonthlyBill monthlyBill) async {
    await _monthlyBillsBox.put(monthlyBill.id, monthlyBill.toJson());
  }
}
