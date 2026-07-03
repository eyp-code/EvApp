import 'package:uuid/uuid.dart';

import '../../../people/domain/models/person.dart';
import 'expense_share.dart';
import 'split_type.dart';

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.totalAmount,
    required this.spentAt,
    required this.paidByPersonId,
    required this.splitType,
    required this.shares,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory Expense.create({
    required String title,
    required String category,
    required double totalAmount,
    required DateTime spentAt,
    required String paidByPersonId,
    required String splitType,
    required List<String> participantIds,
  }) {
    final now = DateTime.now();
    final shares = _createShares(
      totalAmount: totalAmount,
      splitType: splitType,
      participantIds: participantIds,
    );

    return Expense(
      id: const Uuid().v4(),
      title: title,
      category: category,
      totalAmount: totalAmount,
      spentAt: spentAt,
      paidByPersonId: paidByPersonId,
      splitType: splitType,
      shares: shares,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    final sharesJson = (json['shares'] as List<dynamic>? ?? const []);

    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      spentAt: DateTime.parse(json['spentAt'] as String),
      paidByPersonId: json['paidByPersonId'] as String,
      splitType: json['splitType'] as String,
      shares: sharesJson
          .map(
            (value) =>
                ExpenseShare.fromJson(Map<String, dynamic>.from(value as Map)),
          )
          .toList(),
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
  final String title;
  final String category;
  final double totalAmount;
  final DateTime spentAt;
  final String paidByPersonId;
  final String splitType;
  final List<ExpenseShare> shares;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  Expense copyWith({
    String? title,
    String? category,
    double? totalAmount,
    DateTime? spentAt,
    String? paidByPersonId,
    String? splitType,
    List<ExpenseShare>? shares,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      spentAt: spentAt ?? this.spentAt,
      paidByPersonId: paidByPersonId ?? this.paidByPersonId,
      splitType: splitType ?? this.splitType,
      shares: shares ?? this.shares,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Expense markedDeleted() {
    final now = DateTime.now();

    return copyWith(
      updatedAt: now,
      isDeleted: true,
      deletedAt: now,
      syncStatus: SyncStatus.pendingDelete,
    );
  }

  double shareFor(String personId) {
    return shares
        .where((share) => share.personId == personId)
        .fold<double>(0, (total, share) => total + share.amount);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'totalAmount': totalAmount,
      'spentAt': spentAt.toIso8601String(),
      'paidByPersonId': paidByPersonId,
      'splitType': splitType,
      'shares': shares.map((share) => share.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  static List<ExpenseShare> _createShares({
    required double totalAmount,
    required String splitType,
    required List<String> participantIds,
  }) {
    if (participantIds.isEmpty) {
      return const [];
    }

    if (splitType == SplitType.onlyMe) {
      return [
        ExpenseShare(personId: participantIds.first, amount: totalAmount),
      ];
    }

    if (participantIds.length == 1) {
      return [
        ExpenseShare(personId: participantIds.first, amount: totalAmount / 2),
      ];
    }

    final shareAmount = totalAmount / participantIds.length;

    return participantIds
        .map(
          (personId) => ExpenseShare(personId: personId, amount: shareAmount),
        )
        .toList();
  }
}
