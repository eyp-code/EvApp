import 'package:flutter/material.dart';

import '../../../people/domain/models/person.dart';
import '../../../people/domain/repositories/person_repository.dart';
import '../../domain/models/task_item.dart';
import '../../domain/repositories/task_repository.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({
    super.key,
    required this.taskRepository,
    required this.personRepository,
  });

  final TaskRepository taskRepository;
  final PersonRepository personRepository;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Future<List<TaskItem>> _tasksFuture;
  late Future<List<Person>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _tasksFuture = widget.taskRepository.getTasks();
    _personsFuture = widget.personRepository.getPersons();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await Future.wait([_tasksFuture, _personsFuture]);
  }

  Future<void> _addTask({
    required List<Person> persons,
    required bool isRecurring,
  }) async {
    final task = await showDialog<TaskItem>(
      context: context,
      builder: (context) =>
          _AddTaskDialog(persons: persons, initialRecurring: isRecurring),
    );

    if (task == null) {
      return;
    }

    await widget.taskRepository.addTask(task);
    await _refresh();
  }

  Future<void> _toggleCompleted(TaskItem task) async {
    await widget.taskRepository.toggleCompleted(task.id);
    await _refresh();
  }

  Future<void> _deleteTask(TaskItem task) async {
    await widget.taskRepository.deleteTask(task.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: _personsFuture,
      builder: (context, personsSnapshot) {
        final persons = personsSnapshot.data ?? const <Person>[];

        return DefaultTabController(
          length: 2,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _PageHeader(
                title: 'Gorevler',
                subtitle:
                    'Tek seferlik isleri ve ev rutinlerini ayri takip et.',
              ),
              const SizedBox(height: 16),
              const TabBar(
                tabs: [
                  Tab(text: 'Normal'),
                  Tab(text: 'Rutin'),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<TaskItem>>(
                future: _tasksFuture,
                builder: (context, tasksSnapshot) {
                  if (tasksSnapshot.connectionState != ConnectionState.done ||
                      personsSnapshot.connectionState != ConnectionState.done) {
                    return const LinearProgressIndicator();
                  }

                  final tasks = tasksSnapshot.data ?? const <TaskItem>[];
                  final normalTasks = tasks
                      .where((task) => !task.hasRecurringSchedule)
                      .toList();
                  final routineTasks = tasks
                      .where((task) => task.hasRecurringSchedule)
                      .toList();

                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height - 210,
                    child: TabBarView(
                      children: [
                        _TaskTab(
                          title: 'Normal gorevler',
                          emptyTitle: 'Normal gorev yok',
                          emptyDescription:
                              'Bugun yapilacak tek seferlik ev islerini buraya ekle.',
                          addLabel: 'Normal gorev ekle',
                          tasks: normalTasks,
                          onAddPressed: () => _addTask(
                            persons: persons,
                            isRecurring: false,
                          ),
                          onToggleCompleted: _toggleCompleted,
                          onDelete: _deleteTask,
                        ),
                        _TaskTab(
                          title: 'Rutin gorevler',
                          emptyTitle: 'Rutin gorev yok',
                          emptyDescription:
                              'Nevresim, temizlik ve kontrol gibi tekrar eden isleri buraya ekle.',
                          addLabel: 'Rutin gorev ekle',
                          tasks: routineTasks,
                          onAddPressed: () => _addTask(
                            persons: persons,
                            isRecurring: true,
                          ),
                          onToggleCompleted: _toggleCompleted,
                          onDelete: _deleteTask,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskTab extends StatelessWidget {
  const _TaskTab({
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.addLabel,
    required this.tasks,
    required this.onAddPressed,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final String addLabel;
  final List<TaskItem> tasks;
  final VoidCallback onAddPressed;
  final ValueChanged<TaskItem> onToggleCompleted;
  final ValueChanged<TaskItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(addLabel),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _EmptyTasksCard(
            title: emptyTitle,
            description: emptyDescription,
            onAddPressed: onAddPressed,
            addLabel: addLabel,
          )
        else ...[
          _TaskSummaryCard(tasks: tasks),
          const SizedBox(height: 12),
          ...tasks.map(
            (task) => _TaskCard(
              task: task,
              onToggleCompleted: () => onToggleCompleted(task),
              onDelete: () => onDelete(task),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({
    required this.persons,
    required this.initialRecurring,
  });

  final List<Person> persons;
  final bool initialRecurring;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recurrenceIntervalController = TextEditingController(text: '1');
  String? _assignedPersonId;
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  late bool _isRecurring;
  String _recurrenceUnit = RecurrenceUnit.week;

  @override
  void initState() {
    super.initState();
    _assignedPersonId = widget.persons.firstOrNull?.id;
    _isRecurring = widget.initialRecurring;
    if (_isRecurring) {
      _reminderTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recurrenceIntervalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dueDate = pickedDate;
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _reminderTime = pickedTime;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isRecurring && _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rutin gorev icin ilk bildirim gunu sec.')),
      );
      return;
    }

    String? assignedPersonName;
    for (final person in widget.persons) {
      if (person.id == _assignedPersonId) {
        assignedPersonName = person.name;
        break;
      }
    }

    Navigator.of(context).pop(
      TaskItem.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        assignedPersonId: _assignedPersonId,
        assignedPersonName: assignedPersonName,
        dueDate: _dueDate,
        reminderTimeMinutes: _reminderTime == null
            ? null
            : _reminderTime!.hour * 60 + _reminderTime!.minute,
        isRecurring: _isRecurring,
        recurrenceInterval: _isRecurring
            ? int.parse(_recurrenceIntervalController.text.trim())
            : null,
        recurrenceUnit: _isRecurring ? _recurrenceUnit : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isRecurring ? 'Rutin gorev ekle' : 'Normal gorev ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Baslik'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Baslik gerekli';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Aciklama'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _assignedPersonId,
                decoration: const InputDecoration(labelText: 'Sorumlu'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Atanmamis'),
                  ),
                  ...widget.persons.map(
                    (person) => DropdownMenuItem<String?>(
                      value: person.id,
                      child: Text(person.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _assignedPersonId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _PickerField(
                label: _isRecurring ? 'Ilk bildirim gunu' : 'Son tarih',
                value: _dueDate == null ? 'Secilmedi' : _formatDate(_dueDate!),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              _PickerField(
                label: 'Bildirim saati',
                value: _reminderTime == null
                    ? 'Secilmedi'
                    : _formatTime(_reminderTime!.hour * 60 + _reminderTime!.minute),
                icon: Icons.schedule_outlined,
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rutin gorev'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    _reminderTime ??= value
                        ? const TimeOfDay(hour: 9, minute: 0)
                        : _reminderTime;
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _recurrenceIntervalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Tekrar miktari'),
                        validator: (value) {
                          if (!_isRecurring) {
                            return null;
                          }

                          final interval = int.tryParse((value ?? '').trim());
                          if (interval == null || interval <= 0) {
                            return 'Gecerli bir miktar gir';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _recurrenceUnit,
                        decoration: const InputDecoration(labelText: 'Birim'),
                        items: const [
                          DropdownMenuItem(
                            value: RecurrenceUnit.day,
                            child: Text('Gun'),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceUnit.week,
                            child: Text('Hafta'),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceUnit.month,
                            child: Text('Ay'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _recurrenceUnit = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgec'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Kaydet')),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: Icon(icon)),
        child: Align(alignment: Alignment.centerLeft, child: Text(value)),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  final TaskItem task;
  final VoidCallback onToggleCompleted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggleCompleted(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if ((task.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(task.description!),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskInfoChip(
                        label: task.assignedPersonName == null
                            ? 'Atanmamis'
                            : 'Sorumlu: ${task.assignedPersonName}',
                      ),
                      if (task.dueDate != null)
                        _TaskInfoChip(
                          label: task.hasRecurringSchedule
                              ? 'Siradaki bildirim: ${_formatDate(task.dueDate!)}'
                              : 'Son tarih: ${_formatDate(task.dueDate!)}',
                        ),
                      if (task.reminderTimeMinutes != null)
                        _TaskInfoChip(
                          label: 'Saat: ${_formatTime(task.reminderTimeMinutes!)}',
                        ),
                      if (task.lastCompletedAt != null && task.hasRecurringSchedule)
                        _TaskInfoChip(
                          label: 'Son yapilma: ${_formatDate(task.lastCompletedAt!)}',
                        ),
                      if (task.hasRecurringSchedule)
                        _TaskInfoChip(
                          label:
                              'Tekrar: her ${task.recurrenceInterval} ${_recurrenceUnitLabel(task.recurrenceUnit!)}',
                        ),
                      _TaskInfoChip(
                        label: task.isCompleted
                            ? 'Tamamlandi'
                            : task.hasRecurringSchedule && task.lastCompletedAt != null
                            ? 'Devam ediyor'
                            : 'Bekliyor',
                        color: task.isCompleted
                            ? Colors.green.withValues(alpha: 0.14)
                            : colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Gorevi sil',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskInfoChip extends StatelessWidget {
  const _TaskInfoChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final pendingCount = tasks.where((task) => !task.isCompleted).length;
    final completedCount = tasks.where((task) => task.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryStat(label: 'Bekleyen', value: pendingCount.toString()),
            ),
            Expanded(
              child: _SummaryStat(label: 'Tamamlanan', value: completedCount.toString()),
            ),
            Expanded(
              child: _SummaryStat(label: 'Toplam', value: tasks.length.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard({
    required this.title,
    required this.description,
    required this.onAddPressed,
    required this.addLabel,
  });

  final String title;
  final String description;
  final VoidCallback onAddPressed;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.task_alt_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    label: Text(addLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.${date.year}';
}

String _formatTime(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _recurrenceUnitLabel(String unit) {
  return switch (unit) {
    RecurrenceUnit.day => 'gun',
    RecurrenceUnit.week => 'hafta',
    RecurrenceUnit.month => 'ay',
    _ => 'birim',
  };
}
