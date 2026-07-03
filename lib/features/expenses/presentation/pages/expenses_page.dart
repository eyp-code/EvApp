import 'package:flutter/material.dart';

import '../../../people/domain/models/person.dart';
import '../../../people/domain/repositories/person_repository.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/split_type.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
    required this.personRepository,
    required this.expenseRepository,
  });

  final PersonRepository personRepository;
  final ExpenseRepository expenseRepository;

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  late Future<List<Person>> _personsFuture;
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _personsFuture = widget.personRepository.getPersons();
    _expensesFuture = widget.expenseRepository.getExpenses();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await Future.wait([_personsFuture, _expensesFuture]);
  }

  Future<void> _addExpense(List<Person> persons) async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (context) => _AddExpenseDialog(persons: persons),
    );

    if (expense == null) {
      return;
    }

    await widget.expenseRepository.addExpense(expense);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>>(
      future: _personsFuture,
      builder: (context, personsSnapshot) {
        final persons = personsSnapshot.data ?? const <Person>[];
        final me = _findMe(persons);
        final personsLoaded =
            personsSnapshot.connectionState == ConnectionState.done;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHeader(
              title: 'Masraflar',
              subtitle:
                  'Harcama ekle, paylaşım tipini seç ve kendi payını takip et.',
              onAddPressed: !personsLoaded || persons.isEmpty
                  ? null
                  : () => _addExpense(persons),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Expense>>(
              future: _expensesFuture,
              builder: (context, expensesSnapshot) {
                final expenses = expensesSnapshot.data ?? const <Expense>[];

                if (expensesSnapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }

                if (!personsLoaded) {
                  return const LinearProgressIndicator();
                }

                if (expenses.isEmpty) {
                  return _EmptyExpensesCard(
                    onAddPressed: () => _addExpense(persons),
                  );
                }

                return Column(
                  children: expenses
                      .map(
                        (expense) => _ExpenseCard(
                          expense: expense,
                          persons: persons,
                          myPersonId: me?.id,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Person? _findMe(List<Person> persons) {
    for (final person in persons) {
      if (person.isMe) {
        return person;
      }
    }

    return null;
  }
}

class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog({required this.persons});

  final List<Person> persons;

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Market');
  final _amountController = TextEditingController();

  late String _paidByPersonId;
  String _splitType = SplitType.onlyMe;

  @override
  void initState() {
    super.initState();
    _paidByPersonId = widget.persons.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    final me = widget.persons.where((person) => person.isMe).firstOrNull;

    if (title.isEmpty || category.isEmpty || amount == null || amount <= 0) {
      return;
    }

    if (me == null) {
      return;
    }

    final participantIds = _splitType == SplitType.onlyMe
        ? [me.id]
        : widget.persons.map((person) => person.id).toList();

    Navigator.of(context).pop(
      Expense.create(
        title: title,
        category: category,
        totalAmount: amount,
        spentAt: DateTime.now(),
        paidByPersonId: _paidByPersonId,
        splitType: _splitType,
        participantIds: participantIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Masraf ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Tutar'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _paidByPersonId,
              decoration: const InputDecoration(labelText: 'Kim ödedi?'),
              items: widget.persons
                  .map(
                    (person) => DropdownMenuItem(
                      value: person.id,
                      child: Text(person.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _paidByPersonId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: SplitType.onlyMe,
                  label: Text('Sadece benim'),
                ),
                ButtonSegment(
                  value: SplitType.equal,
                  label: Text('Ortak eşit'),
                ),
              ],
              selected: {_splitType},
              onSelectionChanged: (selection) {
                setState(() {
                  _splitType = selection.first;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Kaydet')),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.persons,
    required this.myPersonId,
  });

  final Expense expense;
  final List<Person> persons;
  final String? myPersonId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final myShare = myPersonId == null ? 0.0 : expense.shareFor(myPersonId!);
    final paidBy = _personName(expense.paidByPersonId);
    final splitLabel = expense.splitType == SplitType.equal
        ? 'Ortak eşit bölündü'
        : 'Sadece benim';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category} • Ödeyen: $paidBy',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatAmount(expense.totalAmount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Benim payım: ${_formatAmount(myShare)}'),
                _InfoChip(label: splitLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _personName(String personId) {
    for (final person in persons) {
      if (person.id == personId) {
        return person.name;
      }
    }

    return 'Bilinmeyen';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _EmptyExpensesCard extends StatelessWidget {
  const _EmptyExpensesCard({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Henüz masraf yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İlk masrafı ekleyerek toplam tutarı ve kendi payını görmeye başlayabilirsin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Masraf ekle'),
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
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onAddPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        IconButton.filled(
          tooltip: 'Masraf ekle',
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

String _formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} TL';
}
