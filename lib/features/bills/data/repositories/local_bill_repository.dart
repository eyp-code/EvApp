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
  Future<List<BillType>> getAllBillTypes() {
    return _dataSource.getAllBillTypes();
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
  Future<void> addMonthlyBill(MonthlyBill monthlyBill) async {
    final monthlyBills = await _dataSource.getAllMonthlyBills();
    final existingMonthlyBill = _findMatchingMonthlyBill(
      monthlyBills: monthlyBills,
      monthlyBill: monthlyBill,
    );

    if (existingMonthlyBill == null) {
      await _dataSource.saveMonthlyBill(monthlyBill);
      return;
    }

    await _dataSource.saveMonthlyBill(
      existingMonthlyBill.copyWith(
        billTypeName: monthlyBill.billTypeName,
        amount: monthlyBill.amount ?? existingMonthlyBill.amount,
        dueDate: monthlyBill.dueDate ?? existingMonthlyBill.dueDate,
        note: monthlyBill.note ?? existingMonthlyBill.note,
        status: monthlyBill.status,
        paidAt: monthlyBill.paidAt ?? existingMonthlyBill.paidAt,
        generatedExpenseId:
            monthlyBill.generatedExpenseId ??
            existingMonthlyBill.generatedExpenseId,
        updatedAt: monthlyBill.updatedAt,
        syncStatus: monthlyBill.syncStatus,
      ),
    );
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
  Future<void> skipMonthlyBill(String monthlyBillId) async {
    final monthlyBill = await _dataSource.getMonthlyBillById(monthlyBillId);

    if (monthlyBill == null || monthlyBill.isDeleted || monthlyBill.isSkipped) {
      return;
    }

    await _dataSource.saveMonthlyBill(monthlyBill.markedSkipped());
  }

  @override
  Future<void> restoreMonthlyBill(String monthlyBillId) async {
    final monthlyBill = await _dataSource.getMonthlyBillById(monthlyBillId);

    if (monthlyBill == null || monthlyBill.isDeleted || !monthlyBill.isSkipped) {
      return;
    }

    await _dataSource.saveMonthlyBill(monthlyBill.restoredFromSkip());
  }

  @override
  Future<List<BillType>> getBillTypes() {
    return _dataSource.getBillTypes();
  }

  @override
  Future<List<MonthlyBill>> getAllMonthlyBills() async {
    final monthlyBills = await _dataSource.getAllMonthlyBills();
    return _dedupeMonthlyBills(monthlyBills);
  }

  @override
  Future<List<MonthlyBill>> getMonthlyBills() async {
    final monthlyBills = await _dataSource.getMonthlyBills();
    return _dedupeMonthlyBills(monthlyBills);
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
            !monthlyBill.isDeleted &&
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

  Future<void> replaceAll({
    required List<BillType> billTypes,
    required List<MonthlyBill> monthlyBills,
  }) async {
    await _dataSource.replaceAll(
      billTypes: billTypes,
      monthlyBills: monthlyBills,
    );
  }

  MonthlyBill? _findMatchingMonthlyBill({
    required List<MonthlyBill> monthlyBills,
    required MonthlyBill monthlyBill,
  }) {
    for (final existingMonthlyBill in monthlyBills) {
      final isSameSlot =
          existingMonthlyBill.billTypeId == monthlyBill.billTypeId &&
          existingMonthlyBill.year == monthlyBill.year &&
          existingMonthlyBill.month == monthlyBill.month;

      if (!isSameSlot ||
          existingMonthlyBill.isDeleted ||
          existingMonthlyBill.id == monthlyBill.id) {
        continue;
      }

      return existingMonthlyBill;
    }

    return null;
  }

  List<MonthlyBill> _dedupeMonthlyBills(List<MonthlyBill> monthlyBills) {
    final byKey = <String, MonthlyBill>{};

    for (final monthlyBill in monthlyBills) {
      final key =
          '${monthlyBill.billTypeId}-${monthlyBill.year}-${monthlyBill.month}';
      final existingMonthlyBill = byKey[key];

      if (existingMonthlyBill == null) {
        byKey[key] = monthlyBill;
        continue;
      }

      final preferredMonthlyBill = existingMonthlyBill.updatedAt
              .isAfter(monthlyBill.updatedAt)
          ? existingMonthlyBill
          : monthlyBill;
      final otherMonthlyBill =
          identical(preferredMonthlyBill, existingMonthlyBill)
          ? monthlyBill
          : existingMonthlyBill;

      byKey[key] = _mergeMonthlyBills(preferredMonthlyBill, otherMonthlyBill);
    }

    final result = byKey.values.toList();
    result.sort((first, second) {
      final yearComparison = second.year.compareTo(first.year);
      if (yearComparison != 0) {
        return yearComparison;
      }

      return second.month.compareTo(first.month);
    });
    return result;
  }

  MonthlyBill _mergeMonthlyBills(
    MonthlyBill preferredMonthlyBill,
    MonthlyBill otherMonthlyBill,
  ) {
    return preferredMonthlyBill.copyWith(
      billTypeName: preferredMonthlyBill.billTypeName.isNotEmpty
          ? preferredMonthlyBill.billTypeName
          : otherMonthlyBill.billTypeName,
      amount: preferredMonthlyBill.amount ?? otherMonthlyBill.amount,
      dueDate: preferredMonthlyBill.dueDate ?? otherMonthlyBill.dueDate,
      note: preferredMonthlyBill.note ?? otherMonthlyBill.note,
      paidAt: preferredMonthlyBill.paidAt ?? otherMonthlyBill.paidAt,
      generatedExpenseId:
          preferredMonthlyBill.generatedExpenseId ??
          otherMonthlyBill.generatedExpenseId,
      updatedAt: preferredMonthlyBill.updatedAt,
      syncStatus: preferredMonthlyBill.syncStatus,
    );
  }
}
