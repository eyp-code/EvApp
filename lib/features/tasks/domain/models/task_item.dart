import 'package:uuid/uuid.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.isRecurring = false,
    this.recurrenceInterval,
    this.recurrenceUnit,
    this.description,
    this.assignedPersonId,
    this.assignedPersonName,
    this.dueDate,
    this.reminderTimeMinutes,
    this.completedAt,
    this.deletedAt,
    this.syncStatus = SyncStatus.localOnly,
    this.lastSyncedAt,
  });

  factory TaskItem.create({
    required String title,
    String? description,
    String? assignedPersonId,
    String? assignedPersonName,
    DateTime? dueDate,
    int? reminderTimeMinutes,
    bool isRecurring = false,
    int? recurrenceInterval,
    String? recurrenceUnit,
  }) {
    final now = DateTime.now();

    return TaskItem(
      id: const Uuid().v4(),
      title: title,
      description: description,
      assignedPersonId: assignedPersonId,
      assignedPersonName: assignedPersonName,
      dueDate: dueDate,
      reminderTimeMinutes: reminderTimeMinutes,
      isRecurring: isRecurring,
      recurrenceInterval: isRecurring ? recurrenceInterval : null,
      recurrenceUnit: isRecurring ? recurrenceUnit : null,
      status: TaskStatus.pending,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceInterval: json['recurrenceInterval'] as int?,
      recurrenceUnit: json['recurrenceUnit'] as String?,
      description: json['description'] as String?,
      assignedPersonId: json['assignedPersonId'] as String?,
      assignedPersonName: json['assignedPersonName'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      reminderTimeMinutes: json['reminderTimeMinutes'] as int?,
      status: json['status'] as String? ?? TaskStatus.pending,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
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
  final bool isRecurring;
  final int? recurrenceInterval;
  final String? recurrenceUnit;
  final String? description;
  final String? assignedPersonId;
  final String? assignedPersonName;
  final DateTime? dueDate;
  final int? reminderTimeMinutes;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  bool get isCompleted => status == TaskStatus.completed;
  bool get hasRecurringSchedule =>
      isRecurring &&
      recurrenceInterval != null &&
      recurrenceInterval! > 0 &&
      recurrenceUnit != null;
  DateTime? get lastCompletedAt => completedAt;

  TaskItem copyWith({
    String? title,
    bool? isRecurring,
    int? recurrenceInterval,
    String? recurrenceUnit,
    String? description,
    String? assignedPersonId,
    String? assignedPersonName,
    DateTime? dueDate,
    int? reminderTimeMinutes,
    String? status,
    DateTime? completedAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceUnit: recurrenceUnit ?? this.recurrenceUnit,
      description: description ?? this.description,
      assignedPersonId: assignedPersonId ?? this.assignedPersonId,
      assignedPersonName: assignedPersonName ?? this.assignedPersonName,
      dueDate: dueDate ?? this.dueDate,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  TaskItem toggledCompleted() {
    if (hasRecurringSchedule) {
      return completedRecurring();
    }

    final now = DateTime.now();
    final nextCompleted = !isCompleted;

    return copyWith(
      status: nextCompleted ? TaskStatus.completed : TaskStatus.pending,
      completedAt: nextCompleted ? now : null,
      updatedAt: now,
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  TaskItem completedRecurring() {
    final now = DateTime.now();
    final baseDate = dueDate ?? now;

    return copyWith(
      status: TaskStatus.pending,
      completedAt: now,
      dueDate: _nextDate(
        baseDate: baseDate,
        interval: recurrenceInterval!,
        unit: recurrenceUnit!,
      ),
      updatedAt: now,
      syncStatus: SyncStatus.pendingUpdate,
    );
  }

  TaskItem markedDeleted() {
    final now = DateTime.now();

    return copyWith(
      isDeleted: true,
      deletedAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingDelete,
    );
  }

  static DateTime _nextDate({
    required DateTime baseDate,
    required int interval,
    required String unit,
  }) {
    return switch (unit) {
      RecurrenceUnit.day => baseDate.add(Duration(days: interval)),
      RecurrenceUnit.week => baseDate.add(Duration(days: interval * 7)),
      RecurrenceUnit.month => DateTime(
        baseDate.year,
        baseDate.month + interval,
        baseDate.day,
      ),
      _ => baseDate,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'recurrenceUnit': recurrenceUnit,
      'description': description,
      'assignedPersonId': assignedPersonId,
      'assignedPersonName': assignedPersonName,
      'dueDate': dueDate?.toIso8601String(),
      'reminderTimeMinutes': reminderTimeMinutes,
      'status': status,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }
}

class TaskStatus {
  const TaskStatus._();

  static const pending = 'pending';
  static const completed = 'completed';
}

class RecurrenceUnit {
  const RecurrenceUnit._();

  static const day = 'day';
  static const week = 'week';
  static const month = 'month';
}

class SyncStatus {
  const SyncStatus._();

  static const localOnly = 'localOnly';
  static const pendingUpdate = 'pendingUpdate';
  static const pendingDelete = 'pendingDelete';
}
