import 'package:uuid/uuid.dart';

class Person {
  const Person({
    required this.id,
    required this.name,
    required this.isMe,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.avatarColor,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory Person.createMe({required String name}) {
    final now = DateTime.now();

    return Person(
      id: const Uuid().v4(),
      name: name,
      isMe: true,
      avatarColor: '#1E7A5F',
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      isMe: json['isMe'] as bool,
      avatarColor: json['avatarColor'] as String?,
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
  final bool isMe;
  final String? avatarColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isMe': isMe,
      'avatarColor': avatarColor,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}

class SyncStatus {
  const SyncStatus._();

  static const localOnly = 'localOnly';
  static const synced = 'synced';
  static const pendingCreate = 'pendingCreate';
  static const pendingUpdate = 'pendingUpdate';
  static const pendingDelete = 'pendingDelete';
}
