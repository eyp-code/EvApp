import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';
import '../../../bills/domain/models/bill_status.dart';
import '../../../bills/domain/models/monthly_bill.dart';
import '../../../bills/domain/models/bill_type.dart';
import '../../../bills/domain/repositories/bill_repository.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../people/domain/models/person.dart';
import '../../../people/domain/repositories/person_repository.dart';
import '../../domain/models/monthly_summary.dart';
import '../../domain/services/monthly_summary_service.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({
    super.key,
    required this.personRepository,
    required this.expenseRepository,
    required this.billRepository,
  });

  final PersonRepository personRepository;
  final ExpenseRepository expenseRepository;
  final BillRepository billRepository;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return _PageLayout(
      title: 'Ev Ozeti',
      subtitle: 'Bu ay harcamalar nasil dagildi?',
      children: [
        FutureBuilder<Person?>(
          future: personRepository.getMe(),
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? 'Ben';

            return SectionPlaceholder(
              title: 'Hos geldin, $name',
              description:
                  'Kisi, masraf ve fatura kayitlari local veritabaninda saklaniyor.',
              icon: Icons.person_outline,
            );
          },
        ),
        FutureBuilder<_DashboardData>(
          future: _loadDashboardData(now),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            final data = snapshot.data;
            if (data == null) {
              return const SectionPlaceholder(
                title: 'Aylik ozet hazir degil',
                description: 'Dashboard verisi olusturulamadi.',
                icon: Icons.info_outline,
              );
            }

            return Column(
              children: [
                _FinanceSummaryCard(summary: data.currentMonthSummary),
                const SizedBox(height: 16),
                _BillsOverviewCard(summary: data.currentMonthSummary),
                const SizedBox(height: 16),
                _ArchiveSection(
                  archivedMonths: data.archivedMonths,
                  summariesByMonthKey: data.archivedSummaries,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<_DashboardData> _loadDashboardData(DateTime now) async {
    await billRepository.ensureMonthlyBillsForMonth(
      year: now.year,
      month: now.month,
    );

    final results = await Future.wait([
      personRepository.getMe(),
      expenseRepository.getExpenses(),
      billRepository.getBillTypes(),
      billRepository.getMonthlyBills(),
    ]);

    final me = results[0] as Person?;
    final expenses = results[1] as List<Expense>;
    final billTypes = results[2] as List<BillType>;
    final monthlyBills = _filterVisibleMonthlyBills(
      billTypes: billTypes,
      monthlyBills: results[3] as List<MonthlyBill>,
    );

    if (me == null) {
      return _DashboardData.empty();
    }

    final service = const MonthlySummaryService();
    final currentMonthSummary = service.build(
      me: me,
      year: now.year,
      month: now.month,
      expenses: expenses,
      monthlyBills: monthlyBills,
    );

    final archivedMonths = service.archivedMonths(
      currentMonth: DateTime(now.year, now.month),
      expenses: expenses,
      monthlyBills: monthlyBills,
    );

    final archivedSummaries = <String, MonthlySummary>{};
    for (final month in archivedMonths) {
      archivedSummaries[_monthKey(month.year, month.month)] = service.build(
        me: me,
        year: month.year,
        month: month.month,
        expenses: expenses,
        monthlyBills: monthlyBills,
      );
    }

    return _DashboardData(
      currentMonthSummary: currentMonthSummary,
      archivedMonths: archivedMonths,
      archivedSummaries: archivedSummaries,
    );
  }

  List<MonthlyBill> _filterVisibleMonthlyBills({
    required List<BillType> billTypes,
    required List<MonthlyBill> monthlyBills,
  }) {
    final activeBillTypeIds = billTypes.map((billType) => billType.id).toSet();

    return monthlyBills.where((monthlyBill) {
      return activeBillTypeIds.contains(monthlyBill.billTypeId) ||
          monthlyBill.isPaid ||
          monthlyBill.isSkipped;
    }).toList();
  }
}

class MonthlySummaryPage extends StatelessWidget {
  const MonthlySummaryPage({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_formatMonthYear(summary.month, summary.year))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FinanceSummaryCard(summary: summary),
          const SizedBox(height: 16),
          _BillsOverviewCard(summary: summary),
          const SizedBox(height: 16),
          _MonthlyBillListCard(
            title: 'Odenen faturalar',
            emptyText: 'Bu ay odenmis fatura yok.',
            bills: summary.paidBills,
          ),
          const SizedBox(height: 16),
          _MonthlyBillListCard(
            title: 'Odenmeyen faturalar',
            emptyText: 'Bu ay bekleyen fatura yok.',
            bills: summary.unpaidBills,
          ),
          const SizedBox(height: 16),
          _ExpenseListCard(
            total: summary.enteredExpensesTotal,
            expenses: summary.expenses,
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.currentMonthSummary,
    required this.archivedMonths,
    required this.archivedSummaries,
  });

  factory _DashboardData.empty() {
    return const _DashboardData(
      currentMonthSummary: MonthlySummary(
        year: 0,
        month: 0,
        assignedToMeTotal: 0,
        sharedExpensesTotal: 0,
        mySharedShareTotal: 0,
        onlyMeExpensesTotal: 0,
        enteredExpensesTotal: 0,
        paidBillsCount: 0,
        unpaidBillsCount: 0,
        expenses: [],
        paidBills: [],
        unpaidBills: [],
      ),
      archivedMonths: [],
      archivedSummaries: {},
    );
  }

  final MonthlySummary currentMonthSummary;
  final List<DateTime> archivedMonths;
  final Map<String, MonthlySummary> archivedSummaries;
}

class _FinanceSummaryCard extends StatelessWidget {
  const _FinanceSummaryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bana yazilan toplam',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _formatAmount(summary.assignedToMeTotal),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ortak payim ve sadece bana ait masraflarin toplami.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Ortak masraflar',
              value: _formatAmount(summary.sharedExpensesTotal),
            ),
            _SummaryRow(
              label: 'Benim ortak payim',
              value: _formatAmount(summary.mySharedShareTotal),
            ),
            _SummaryRow(
              label: 'Sadece benim masraflarim',
              value: _formatAmount(summary.onlyMeExpensesTotal),
            ),
            _SummaryRow(
              label: 'Bu ay girilen toplam',
              value: _formatAmount(summary.enteredExpensesTotal),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillsOverviewCard extends StatelessWidget {
  const _BillsOverviewCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu ay faturalar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Odenen fatura sayisi',
              value: summary.paidBills.length.toString(),
            ),
            _SummaryRow(
              label: 'Odenmeyen fatura sayisi',
              value: summary.unpaidBills.length.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveSection extends StatelessWidget {
  const _ArchiveSection({
    required this.archivedMonths,
    required this.summariesByMonthKey,
  });

  final List<DateTime> archivedMonths;
  final Map<String, MonthlySummary> summariesByMonthKey;

  @override
  Widget build(BuildContext context) {
    if (archivedMonths.isEmpty) {
      return const SectionPlaceholder(
        title: 'Biten ay ozeti yok',
        description:
            'Ilk kapanan ay olustugunda burada aylik rapor kartlari birikecek.',
        icon: Icons.archive_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biten aylar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...archivedMonths.map((month) {
              final summary = summariesByMonthKey[_monthKey(
                month.year,
                month.month,
              )];

              if (summary == null) {
                return const SizedBox.shrink();
              }

              return _ArchiveSummaryTile(summary: summary);
            }),
          ],
        ),
      ),
    );
  }
}

class _ArchiveSummaryTile extends StatelessWidget {
  const _ArchiveSummaryTile({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => MonthlySummaryPage(summary: summary),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMonthYear(summary.month, summary.year),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bana yazilan toplam: ${_formatAmount(summary.assignedToMeTotal)}',
                    ),
                    Text(
                      'Faturalar: ${summary.paidBills.length} odenen, ${summary.unpaidBills.length} odenmeyen',
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyBillListCard extends StatelessWidget {
  const _MonthlyBillListCard({
    required this.title,
    required this.emptyText,
    required this.bills,
  });

  final String title;
  final String emptyText;
  final List<MonthlyBill> bills;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (bills.isEmpty)
              Text(emptyText)
            else
              ...bills.map(
                (bill) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: Text(bill.billTypeName)),
                      Text(_statusLabel(bill.status)),
                      const SizedBox(width: 12),
                      Text(
                        bill.amount == null ? '-' : _formatAmount(bill.amount!),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListCard extends StatelessWidget {
  const _ExpenseListCard({required this.total, required this.expenses});

  final double total;
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masraflar ozeti',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('Toplam: ${_formatAmount(total)}'),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              const Text('Bu ay masraf yok.')
            else
              ...expenses.map(
                (expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.title),
                            Text(
                              '${expense.category} - ${_formatDate(expense.spentAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(_formatAmount(expense.totalAmount)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PageLayout extends StatelessWidget {
  const _PageLayout({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}

String _formatAmount(double amount) {
  return '${amount.toStringAsFixed(2)} TL';
}

String _formatMonthYear(int month, int year) {
  const monthNames = [
    'Ocak',
    'Subat',
    'Mart',
    'Nisan',
    'Mayis',
    'Haziran',
    'Temmuz',
    'Agustos',
    'Eylul',
    'Ekim',
    'Kasim',
    'Aralik',
  ];

  return '${monthNames[month - 1]} $year';
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String _statusLabel(String status) {
  return switch (status) {
    BillStatus.amountWaiting => 'Tutar Bekleniyor',
    BillStatus.readyToPay => 'Odenmeye Hazir',
    BillStatus.paid => 'Odendi',
    BillStatus.overdue => 'Gecikti',
    _ => 'Bilinmeyen',
  };
}

String _monthKey(int year, int month) => '$year-$month';
