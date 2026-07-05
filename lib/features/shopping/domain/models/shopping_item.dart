import 'package:uuid/uuid.dart';

import '../../../people/domain/models/person.dart';

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.isPurchased,
    required this.isDeleted,
    this.estimatedPrice,
    this.purchasedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory ShoppingItem.create({
    required String name,
    required String category,
    double? estimatedPrice,
  }) {
    final now = DateTime.now();

    return ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      estimatedPrice: estimatedPrice,
      createdAt: now,
      updatedAt: now,
      isPurchased: false,
      isDeleted: false,
    );
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPurchased: json['isPurchased'] as bool? ?? false,
      purchasedAt: json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
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
  final double? estimatedPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  ShoppingItem copyWith({
    String? name,
    String? category,
    double? estimatedPrice,
    DateTime? updatedAt,
    bool? isPurchased,
    DateTime? purchasedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  ShoppingItem toggledPurchased() {
    final now = DateTime.now();

    return copyWith(
      updatedAt: now,
      isPurchased: !isPurchased,
      purchasedAt: isPurchased ? null : now,
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  ShoppingItem markedDeleted() {
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
      'estimatedPrice': estimatedPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPurchased': isPurchased,
      'purchasedAt': purchasedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}
