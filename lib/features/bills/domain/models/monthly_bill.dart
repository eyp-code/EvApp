import 'package:uuid/uuid.dart';

import '../../../people/domain/models/person.dart';
import 'bill_status.dart';
import 'bill_type.dart';

class MonthlyBill {
  const MonthlyBill({
    required this.id,
    required this.billTypeId,
    required this.billTypeName,
    required this.year,
    required this.month,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.amount,
    this.dueDate,
    this.note,
    this.paidAt,
    this.generatedExpenseId,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory MonthlyBill.create({
    required String billTypeId,
    required String billTypeName,
    required int year,
    required int month,
    double? amount,
    DateTime? dueDate,
    String? note,
  }) {
    final now = DateTime.now();

    return MonthlyBill(
      id: const Uuid().v4(),
      billTypeId: billTypeId,
      billTypeName: billTypeName,
      year: year,
      month: month,
      amount: amount,
      dueDate: dueDate,
      note: note,
      status: amount == null ? BillStatus.amountWaiting : BillStatus.readyToPay,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory MonthlyBill.fromBillType({
    required BillType billType,
    required int year,
    required int month,
  }) {
    return MonthlyBill.create(
      billTypeId: billType.id,
      billTypeName: billType.name,
      year: year,
      month: month,
      amount: billType.hasFixedAmount ? billType.fixedAmount : null,
    );
  }

  factory MonthlyBill.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble();
    final legacyIsPaid = json['isPaid'] as bool?;

    return MonthlyBill(
      id: json['id'] as String,
      billTypeId: json['billTypeId'] as String,
      billTypeName: json['billTypeName'] as String? ?? 'Silinen fatura',
      year: json['year'] as int,
      month: json['month'] as int,
      amount: amount,
      status:
          json['status'] as String? ??
          (legacyIsPaid == true
              ? BillStatus.paid
              : amount == null
              ? BillStatus.amountWaiting
              : BillStatus.readyToPay),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      note: json['note'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      generatedExpenseId: json['generatedExpenseId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? SyncStatus.localOnly,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );
  }

  final String id;
  final String billTypeId;
  final String billTypeName;
  final int year;
  final int month;
  final double? amount;
  final String status;
  final DateTime? dueDate;
  final String? note;
  final DateTime? paidAt;
  final String? generatedExpenseId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  bool get isPaid => status == BillStatus.paid;
  bool get isSkipped => status == BillStatus.skipped;

  MonthlyBill copyWith({
    String? billTypeId,
    String? billTypeName,
    int? year,
    int? month,
    double? amount,
    String? status,
    DateTime? dueDate,
    String? note,
    DateTime? paidAt,
    String? generatedExpenseId,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return MonthlyBill(
      id: id,
      billTypeId: billTypeId ?? this.billTypeId,
      billTypeName: billTypeName ?? this.billTypeName,
      year: year ?? this.year,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      paidAt: paidAt ?? this.paidAt,
      generatedExpenseId: generatedExpenseId ?? this.generatedExpenseId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  MonthlyBill markedPaid({String? generatedExpenseId}) {
    final now = DateTime.now();

    return copyWith(
      status: BillStatus.paid,
      paidAt: now,
      generatedExpenseId: generatedExpenseId,
      updatedAt: now,
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  MonthlyBill markedSkipped() {
    return copyWith(
      status: BillStatus.skipped,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  MonthlyBill restoredFromSkip() {
    return copyWith(
      status: amount == null ? BillStatus.amountWaiting : BillStatus.readyToPay,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  MonthlyBill withDetails({
    required double amount,
    DateTime? dueDate,
    String? note,
  }) {
    return copyWith(
      amount: amount,
      dueDate: dueDate,
      note: note,
      status: BillStatus.readyToPay,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  MonthlyBill markedDeleted() {
    final now = DateTime.now();

    return copyWith(
      updatedAt: now,
      isDeleted: true,
      deletedAt: now,
      syncStatus: SyncStatus.pendingDelete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billTypeId': billTypeId,
      'billTypeName': billTypeName,
      'year': year,
      'month': month,
      'amount': amount,
      'status': status,
      'isPaid': isPaid,
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'paidAt': paidAt?.toIso8601String(),
      'generatedExpenseId': generatedExpenseId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}
