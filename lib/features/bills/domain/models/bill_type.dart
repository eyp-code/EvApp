import 'package:uuid/uuid.dart';

import '../../../people/domain/models/person.dart';
import 'bill_category.dart';
import 'bill_share_type.dart';

class BillType {
  const BillType({
    required this.id,
    required this.name,
    required this.category,
    required this.isRecurringMonthly,
    required this.hasFixedAmount,
    required this.shareType,
    required this.mySharePercentage,
    required this.partnerSharePercentage,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.fixedAmount,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory BillType.create({
    required String name,
    String category = BillCategory.sharedHome,
    bool isRecurringMonthly = true,
    bool hasFixedAmount = false,
    double? fixedAmount,
    String shareType = BillShareType.equal,
    double mySharePercentage = 50,
    double partnerSharePercentage = 50,
  }) {
    final now = DateTime.now();

    return BillType(
      id: const Uuid().v4(),
      name: name,
      category: category,
      isRecurringMonthly: isRecurringMonthly,
      hasFixedAmount: hasFixedAmount,
      fixedAmount: fixedAmount,
      shareType: shareType,
      mySharePercentage: mySharePercentage,
      partnerSharePercentage: partnerSharePercentage,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory BillType.fromJson(Map<String, dynamic> json) {
    return BillType(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? BillCategory.sharedHome,
      isRecurringMonthly: json['isRecurringMonthly'] as bool? ?? true,
      hasFixedAmount: json['hasFixedAmount'] as bool? ?? false,
      fixedAmount: (json['fixedAmount'] as num?)?.toDouble(),
      shareType: json['shareType'] as String? ?? BillShareType.equal,
      mySharePercentage: (json['mySharePercentage'] as num?)?.toDouble() ?? 50,
      partnerSharePercentage:
          (json['partnerSharePercentage'] as num?)?.toDouble() ?? 50,
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
  final String name;
  final String category;
  final bool isRecurringMonthly;
  final bool hasFixedAmount;
  final double? fixedAmount;
  final String shareType;
  final double mySharePercentage;
  final double partnerSharePercentage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  BillType copyWith({
    String? name,
    String? category,
    bool? isRecurringMonthly,
    bool? hasFixedAmount,
    double? fixedAmount,
    String? shareType,
    double? mySharePercentage,
    double? partnerSharePercentage,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return BillType(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      isRecurringMonthly: isRecurringMonthly ?? this.isRecurringMonthly,
      hasFixedAmount: hasFixedAmount ?? this.hasFixedAmount,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      shareType: shareType ?? this.shareType,
      mySharePercentage: mySharePercentage ?? this.mySharePercentage,
      partnerSharePercentage:
          partnerSharePercentage ?? this.partnerSharePercentage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  BillType markedDeleted() {
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
      'name': name,
      'category': category,
      'isRecurringMonthly': isRecurringMonthly,
      'hasFixedAmount': hasFixedAmount,
      'fixedAmount': fixedAmount,
      'shareType': shareType,
      'mySharePercentage': mySharePercentage,
      'partnerSharePercentage': partnerSharePercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}
