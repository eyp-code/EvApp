import '../../domain/models/bill_type.dart';
import '../../domain/models/monthly_bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../data_sources/bill_local_data_source.dart';

class LocalBillRepository implements BillRepository {
  const LocalBillRepository(this._dataSource);

  final BillLocalDataSource _dataSource;

  @override
  Future<void> addBillType(BillType billType) {
    return _dataSource.saveBillType(billType);
  }

  @override
  Future<void> deleteBillType(String billTypeId) async {
    final billType = await _dataSource.getBillTypeById(billTypeId);

    if (billType == null) {
      return;
    }

    await _dataSource.saveBillType(billType.markedDeleted());
  }

  @override
  Future<void> addMonthlyBill(MonthlyBill monthlyBill) {
    return _dataSource.saveMonthlyBill(monthlyBill);
  }

  @override
  Future<void> deleteMonthlyBill(String monthlyBillId) async {
    final monthlyBill = await _dataSource.getMonthlyBillById(monthlyBillId);

    if (monthlyBill == null) {
      return;
    }

    await _dataSource.saveMonthlyBill(monthlyBill.markedDeleted());
  }

  @override
  Future<List<BillType>> getBillTypes() {
    return _dataSource.getBillTypes();
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBills() {
    return _dataSource.getMonthlyBills();
  }

  @override
  Future<void> ensureMonthlyBillsForMonth({
    required int year,
    required int month,
  }) async {
    final billTypes = await _dataSource.getBillTypes();
    final monthlyBills = await _dataSource.getAllMonthlyBills();

    for (final billType in billTypes.where((item) => item.isRecurringMonthly)) {
      final alreadyExists = monthlyBills.any(
        (monthlyBill) =>
            monthlyBill.billTypeId == billType.id &&
            monthlyBill.year == year &&
            monthlyBill.month == month,
      );

      if (alreadyExists) {
        continue;
      }

      await _dataSource.saveMonthlyBill(
        MonthlyBill.fromBillType(billType: billType, year: year, month: month),
      );
    }
  }

  @override
  Future<void> markMonthlyBillPaid({
    required String monthlyBillId,
    String? generatedExpenseId,
  }) async {
    final monthlyBill = await _dataSource.getMonthlyBillById(monthlyBillId);

    if (monthlyBill == null || monthlyBill.isPaid) {
      return;
    }

    await _dataSource.saveMonthlyBill(
      monthlyBill.markedPaid(generatedExpenseId: generatedExpenseId),
    );
  }
}
