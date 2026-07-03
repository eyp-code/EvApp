import 'package:flutter/material.dart';

import '../../domain/models/bill_category.dart';
import '../../domain/models/bill_share_type.dart';
import '../../domain/models/bill_status.dart';
import '../../domain/models/bill_type.dart';
import '../../domain/models/monthly_bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../../expenses/domain/models/split_type.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../people/domain/repositories/person_repository.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({
    super.key,
    required this.billRepository,
    required this.expenseRepository,
    required this.personRepository,
  });

  final BillRepository billRepository;
  final ExpenseRepository expenseRepository;
  final PersonRepository personRepository;

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late Future<_BillsState> _billsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _billsFuture = _loadBills();
  }

  Future<_BillsState> _loadBills() async {
    final now = DateTime.now();
    await widget.billRepository.ensureMonthlyBillsForMonth(
      year: now.year,
      month: now.month,
    );

    final results = await Future.wait([
      widget.billRepository.getBillTypes(),
      widget.billRepository.getMonthlyBills(),
    ]);

    final billTypes = results[0] as List<BillType>;
    final activeBillTypeIds = billTypes.map((billType) => billType.id).toSet();
    final monthlyBills = (results[1] as List<MonthlyBill>)
        .where(
          (monthlyBill) =>
              activeBillTypeIds.contains(monthlyBill.billTypeId) ||
              monthlyBill.isPaid,
        )
        .toList();

    return _BillsState(billTypes: billTypes, monthlyBills: monthlyBills);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _billsFuture;
  }

  Future<void> _addBillType() async {
    final billType = await showDialog<BillType>(
      context: context,
      builder: (context) => const _AddBillTypeDialog(),
    );

    if (billType == null) {
      return;
    }

    await widget.billRepository.addBillType(billType);
    final now = DateTime.now();
    await widget.billRepository.ensureMonthlyBillsForMonth(
      year: now.year,
      month: now.month,
    );
    await _refresh();
  }

  Future<void> _addMonthlyBill(List<BillType> billTypes) async {
    final monthlyBill = await showDialog<MonthlyBill>(
      context: context,
      builder: (context) => _AddMonthlyBillDialog(billTypes: billTypes),
    );

    if (monthlyBill == null) {
      return;
    }

    await widget.billRepository.addMonthlyBill(monthlyBill);
    await _refresh();
  }

  Future<void> _markPaid(MonthlyBill monthlyBill) async {
    if (monthlyBill.amount == null || monthlyBill.amount! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödemeden önce tutar girilmeli.')),
      );
      return;
    }

    if (monthlyBill.generatedExpenseId != null) {
      await widget.billRepository.markMonthlyBillPaid(
        monthlyBillId: monthlyBill.id,
        generatedExpenseId: monthlyBill.generatedExpenseId,
      );
      await _refresh();
      return;
    }

    final billTypes = await widget.billRepository.getBillTypes();
    final billType = _findBillType(billTypes, monthlyBill.billTypeId);
    final persons = await widget.personRepository.getPersons();
    final me = persons.where((person) => person.isMe).firstOrNull;

    if (billType == null || me == null) {
      return;
    }

    final isOnlyMe = billType.category == BillCategory.personal;
    final participantIds = isOnlyMe
        ? [me.id]
        : persons.map((person) => person.id).toList();
    final expense = Expense.create(
      title: billType.name,
      category: 'Fatura',
      totalAmount: monthlyBill.amount!,
      spentAt: DateTime.now(),
      paidByPersonId: me.id,
      splitType: isOnlyMe ? SplitType.onlyMe : SplitType.equal,
      participantIds: participantIds,
    );

    await widget.expenseRepository.addExpense(expense);
    await widget.billRepository.markMonthlyBillPaid(
      monthlyBillId: monthlyBill.id,
      generatedExpenseId: expense.id,
    );
    await _refresh();
  }

  Future<void> _addBillDetails(MonthlyBill monthlyBill) async {
    final updatedBill = await showDialog<MonthlyBill>(
      context: context,
      builder: (context) => _BillDetailsDialog(monthlyBill: monthlyBill),
    );

    if (updatedBill == null) {
      return;
    }

    await widget.billRepository.addMonthlyBill(updatedBill);
    await _refresh();
  }

  Future<void> _deleteBillType(BillType billType) async {
    await widget.billRepository.deleteBillType(billType.id);
    await _refresh();
  }

  Future<void> _deleteMonthlyBill(MonthlyBill monthlyBill) async {
    final generatedExpenseId = monthlyBill.generatedExpenseId;
    if (generatedExpenseId != null) {
      await widget.expenseRepository.deleteExpense(generatedExpenseId);
    }

    await widget.billRepository.deleteMonthlyBill(monthlyBill.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BillsState>(
      future: _billsFuture,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _BillsState.empty();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PageHeader(
              title: 'Faturalar',
              subtitle:
                  'Tekrarlayan ve tek seferlik faturaları ay ay takip et.',
              onAddTypePressed: _addBillType,
              onAddBillPressed: state.billTypes.isEmpty
                  ? null
                  : () => _addMonthlyBill(state.billTypes),
            ),
            const SizedBox(height: 20),
            if (snapshot.connectionState != ConnectionState.done)
              const LinearProgressIndicator()
            else ...[
              _BillTypesSection(
                billTypes: state.billTypes,
                onAddPressed: _addBillType,
                onDeletePressed: _deleteBillType,
              ),
              const SizedBox(height: 16),
              _MonthlyBillsSection(
                billTypes: state.billTypes,
                monthlyBills: state.monthlyBills,
                onAddPressed: state.billTypes.isEmpty
                    ? null
                    : () => _addMonthlyBill(state.billTypes),
                onAddDetails: _addBillDetails,
                onDeleteMonthlyBill: _deleteMonthlyBill,
                onMarkPaid: _markPaid,
              ),
            ],
          ],
        );
      },
    );
  }

  BillType? _findBillType(List<BillType> billTypes, String id) {
    for (final billType in billTypes) {
      if (billType.id == id) {
        return billType;
      }
    }

    return null;
  }
}

class _BillsState {
  const _BillsState({required this.billTypes, required this.monthlyBills});

  factory _BillsState.empty() {
    return const _BillsState(billTypes: [], monthlyBills: []);
  }

  final List<BillType> billTypes;
  final List<MonthlyBill> monthlyBills;
}

class _AddBillTypeDialog extends StatefulWidget {
  const _AddBillTypeDialog();

  @override
  State<_AddBillTypeDialog> createState() => _AddBillTypeDialogState();
}

class _AddBillTypeDialogState extends State<_AddBillTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fixedAmountController = TextEditingController();

  String _category = BillCategory.sharedHome;
  bool _isRecurringMonthly = true;
  bool _hasFixedAmount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fixedAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fixedAmount = _hasFixedAmount
        ? double.parse(_fixedAmountController.text.trim().replaceAll(',', '.'))
        : null;
    final isPersonal = _category == BillCategory.personal;
    final shareType = isPersonal ? BillShareType.onlyMe : BillShareType.equal;
    final mySharePercentage = isPersonal ? 100.0 : 50.0;
    final partnerSharePercentage = isPersonal ? 0.0 : 50.0;

    Navigator.of(context).pop(
      BillType.create(
        name: _nameController.text.trim(),
        category: _category,
        isRecurringMonthly: _isRecurringMonthly,
        hasFixedAmount: _hasFixedAmount,
        fixedAmount: fixedAmount,
        shareType: shareType,
        mySharePercentage: mySharePercentage,
        partnerSharePercentage: partnerSharePercentage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fatura türü ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Fatura adı'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Fatura adı gerekli';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: BillCategory.sharedHome,
                    label: Text('Ev faturası'),
                  ),
                  ButtonSegment(
                    value: BillCategory.personal,
                    label: Text('Kişisel'),
                  ),
                ],
                selected: {_category},
                onSelectionChanged: (selection) {
                  setState(() {
                    _category = selection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aylık tekrarlayan'),
                value: _isRecurringMonthly,
                onChanged: (value) {
                  setState(() {
                    _isRecurringMonthly = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sabit tutar'),
                value: _hasFixedAmount,
                onChanged: (value) {
                  setState(() {
                    _hasFixedAmount = value;
                  });
                },
              ),
              if (_hasFixedAmount) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fixedAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Sabit tutar'),
                  validator: (value) {
                    if (!_hasFixedAmount) {
                      return null;
                    }

                    final amount = double.tryParse(
                      (value ?? '').trim().replaceAll(',', '.'),
                    );

                    if (amount == null || amount <= 0) {
                      return 'Geçerli bir tutar gir';
                    }

                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _category == BillCategory.personal
                      ? 'Paylaşım: Sadece bana ait'
                      : 'Paylaşım: Ortak eşit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
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

class _AddMonthlyBillDialog extends StatefulWidget {
  const _AddMonthlyBillDialog({required this.billTypes});

  final List<BillType> billTypes;

  @override
  State<_AddMonthlyBillDialog> createState() => _AddMonthlyBillDialogState();
}

class _AddMonthlyBillDialogState extends State<_AddMonthlyBillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _billTypeId;
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _billTypeId = widget.billTypes.first.id;
    _year = now.year;
    _month = now.month;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = amountText.isEmpty ? null : double.parse(amountText);
    final note = _noteController.text.trim();
    final billTypeName = _selectedBillTypeName();

    Navigator.of(context).pop(
      MonthlyBill.create(
        billTypeId: _billTypeId,
        billTypeName: billTypeName,
        year: _year,
        month: _month,
        amount: amount,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  String _selectedBillTypeName() {
    for (final billType in widget.billTypes) {
      if (billType.id == _billTypeId) {
        return billType.name;
      }
    }

    return 'Fatura';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aylık fatura ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _billTypeId,
                decoration: const InputDecoration(labelText: 'Fatura türü'),
                items: widget.billTypes
                    .map(
                      (billType) => DropdownMenuItem(
                        value: billType.id,
                        child: Text(billType.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _billTypeId = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _month,
                      decoration: const InputDecoration(labelText: 'Ay'),
                      items: List.generate(12, (index) => index + 1)
                          .map(
                            (month) => DropdownMenuItem(
                              value: month,
                              child: Text(_monthName(month)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _month = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _year,
                      decoration: const InputDecoration(labelText: 'Yıl'),
                      items:
                          List.generate(
                                5,
                                (index) => DateTime.now().year - 2 + index,
                              )
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _year = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  helperText: 'Henüz belli değilse boş bırak',
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final amountText = (value ?? '').trim().replaceAll(',', '.');
                  if (amountText.isEmpty) {
                    return null;
                  }

                  final amount = double.tryParse(amountText);

                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir tutar gir';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Not',
                  helperText: 'İsteğe bağlı',
                ),
              ),
            ],
          ),
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

class _BillDetailsDialog extends StatefulWidget {
  const _BillDetailsDialog({required this.monthlyBill});

  final MonthlyBill monthlyBill;

  @override
  State<_BillDetailsDialog> createState() => _BillDetailsDialogState();
}

class _BillDetailsDialogState extends State<_BillDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.monthlyBill.amount?.toStringAsFixed(2) ?? '',
    );
    _noteController = TextEditingController(
      text: widget.monthlyBill.note ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final note = _noteController.text.trim();

    Navigator.of(context).pop(
      widget.monthlyBill.withDetails(
        amount: double.parse(
          _amountController.text.trim().replaceAll(',', '.'),
        ),
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fatura tutarı gir'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Tutar'),
              validator: (value) {
                final amount = double.tryParse(
                  (value ?? '').trim().replaceAll(',', '.'),
                );

                if (amount == null || amount <= 0) {
                  return 'Geçerli bir tutar gir';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Not',
                helperText: 'İsteğe bağlı',
              ),
              onFieldSubmitted: (_) => _submit(),
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

class _BillTypesSection extends StatelessWidget {
  const _BillTypesSection({
    required this.billTypes,
    required this.onAddPressed,
    required this.onDeletePressed,
  });

  final List<BillType> billTypes;
  final VoidCallback onAddPressed;
  final ValueChanged<BillType> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Fatura türleri',
      action: TextButton.icon(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add),
        label: const Text('Tür ekle'),
      ),
      child: billTypes.isEmpty
          ? const _EmptyText(
              'Önce su, elektrik veya kira gibi bir fatura türü ekle.',
            )
          : Column(
              children: billTypes
                  .map(
                    (billType) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(billType.name),
                      subtitle: Text(
                        billType.isRecurringMonthly
                            ? 'Aylık tekrarlayan'
                            : 'Tek seferlik',
                      ),
                      trailing: IconButton(
                        tooltip: 'Fatura türünü sil',
                        onPressed: () => onDeletePressed(billType),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _MonthlyBillsSection extends StatelessWidget {
  const _MonthlyBillsSection({
    required this.billTypes,
    required this.monthlyBills,
    required this.onAddPressed,
    required this.onAddDetails,
    required this.onDeleteMonthlyBill,
    required this.onMarkPaid,
  });

  final List<BillType> billTypes;
  final List<MonthlyBill> monthlyBills;
  final VoidCallback? onAddPressed;
  final ValueChanged<MonthlyBill> onAddDetails;
  final ValueChanged<MonthlyBill> onDeleteMonthlyBill;
  final ValueChanged<MonthlyBill> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Aylık faturalar',
      action: TextButton.icon(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add),
        label: const Text('Fatura ekle'),
      ),
      child: monthlyBills.isEmpty
          ? const _EmptyText('Aylık fatura kaydı henüz yok.')
          : _GroupedMonthlyBills(
              monthlyBills: monthlyBills,
              billTypeNameFor: _billTypeName,
              onAddDetails: onAddDetails,
              onDeleteMonthlyBill: onDeleteMonthlyBill,
              onMarkPaid: onMarkPaid,
            ),
    );
  }

  String _billTypeName(MonthlyBill monthlyBill) {
    for (final billType in billTypes) {
      if (billType.id == monthlyBill.billTypeId) {
        return billType.name;
      }
    }

    return monthlyBill.billTypeName;
  }
}

class _GroupedMonthlyBills extends StatelessWidget {
  const _GroupedMonthlyBills({
    required this.monthlyBills,
    required this.billTypeNameFor,
    required this.onAddDetails,
    required this.onDeleteMonthlyBill,
    required this.onMarkPaid,
  });

  final List<MonthlyBill> monthlyBills;
  final String Function(MonthlyBill monthlyBill) billTypeNameFor;
  final ValueChanged<MonthlyBill> onAddDetails;
  final ValueChanged<MonthlyBill> onDeleteMonthlyBill;
  final ValueChanged<MonthlyBill> onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<MonthlyBill>>{};

    for (final monthlyBill in monthlyBills) {
      final key = '${monthlyBill.year}-${monthlyBill.month}';
      groups.putIfAbsent(key, () => []).add(monthlyBill);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.entries.map((entry) {
        final firstBill = entry.value.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Text(
                '${_monthName(firstBill.month)} ${firstBill.year}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...entry.value.map(
              (monthlyBill) => _MonthlyBillTile(
                monthlyBill: monthlyBill,
                billTypeName: billTypeNameFor(monthlyBill),
                onAddDetails: () => onAddDetails(monthlyBill),
                onDelete: () => onDeleteMonthlyBill(monthlyBill),
                onMarkPaid: () => onMarkPaid(monthlyBill),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

class _MonthlyBillTile extends StatelessWidget {
  const _MonthlyBillTile({
    required this.monthlyBill,
    required this.billTypeName,
    required this.onAddDetails,
    required this.onDelete,
    required this.onMarkPaid,
  });

  final MonthlyBill monthlyBill;
  final String billTypeName;
  final VoidCallback onAddDetails;
  final VoidCallback onDelete;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            monthlyBill.isPaid
                ? Icons.check_circle_outline
                : Icons.pending_actions_outlined,
            color: monthlyBill.isPaid ? Colors.green : colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billTypeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_monthName(monthlyBill.month)} ${monthlyBill.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _statusLabel(monthlyBill.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _statusColor(monthlyBill.status, colorScheme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (monthlyBill.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    monthlyBill.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                monthlyBill.amount == null
                    ? '-'
                    : _formatAmount(monthlyBill.amount!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (monthlyBill.amount == null && !monthlyBill.isPaid)
                TextButton(
                  onPressed: onAddDetails,
                  child: const Text('Tutar gir'),
                )
              else if (!monthlyBill.isPaid)
                TextButton(
                  onPressed: onMarkPaid,
                  child: const Text('Ödendi işaretle'),
                ),
              IconButton(
                tooltip: 'Aylık faturayı sil',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.action,
    required this.child,
  });

  final String title;
  final Widget action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                action,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onAddTypePressed,
    required this.onAddBillPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAddTypePressed;
  final VoidCallback? onAddBillPressed;

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
        IconButton.filledTonal(
          tooltip: 'Fatura türü ekle',
          onPressed: onAddTypePressed,
          icon: const Icon(Icons.playlist_add),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Aylık fatura ekle',
          onPressed: onAddBillPressed,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

String _formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} TL';
}

String _statusLabel(String status) {
  return switch (status) {
    BillStatus.amountWaiting => 'Tutar Bekleniyor',
    BillStatus.readyToPay => 'Ödenmeye Hazır',
    BillStatus.paid => 'Ödendi',
    BillStatus.overdue => 'Gecikti',
    _ => 'Bilinmeyen',
  };
}

Color _statusColor(String status, ColorScheme colorScheme) {
  return switch (status) {
    BillStatus.amountWaiting => colorScheme.tertiary,
    BillStatus.readyToPay => colorScheme.primary,
    BillStatus.paid => Colors.green,
    BillStatus.overdue => colorScheme.error,
    _ => colorScheme.onSurfaceVariant,
  };
}

String _monthName(int month) {
  const monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  if (month < 1 || month > monthNames.length) {
    return 'Bilinmeyen';
  }

  return monthNames[month - 1];
}
