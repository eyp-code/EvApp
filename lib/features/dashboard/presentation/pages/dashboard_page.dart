import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';
import '../../../expenses/domain/models/expense.dart';
import '../../../expenses/domain/models/split_type.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../people/domain/models/person.dart';
import '../../../people/domain/repositories/person_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.personRepository,
    required this.expenseRepository,
  });

  final PersonRepository personRepository;
  final ExpenseRepository expenseRepository;

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      title: 'Ev Özeti',
      subtitle: 'Bu ay harcamalar nasıl dağıldı?',
      children: [
        FutureBuilder(
          future: personRepository.getMe(),
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? 'Ben';

            return SectionPlaceholder(
              title: 'Hoş geldin, $name',
              description:
                  'Kişi ve masraf kayıtları local veritabanında saklanıyor.',
              icon: Icons.person_outline,
            );
          },
        ),
        FutureBuilder<_DashboardExpenseSummary>(
          future: _loadExpenseSummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            return _FinanceSummaryCard(
              summary: snapshot.data ?? _DashboardExpenseSummary.empty(),
            );
          },
        ),
        const SectionPlaceholder(
          title: 'Bekleyen işler',
          description:
              'Girilmemiş faturalar, yaklaşan abonelikler ve görevler burada toplanacak.',
          icon: Icons.notifications_active_outlined,
        ),
      ],
    );
  }

  Future<_DashboardExpenseSummary> _loadExpenseSummary() async {
    final results = await Future.wait([
      personRepository.getMe(),
      expenseRepository.getExpenses(),
    ]);

    final me = results[0] as Person?;
    final expenses = results[1] as List<Expense>;

    if (me == null) {
      return _DashboardExpenseSummary.empty();
    }

    final enteredTotal = expenses.fold<double>(
      0,
      (total, expense) => total + expense.totalAmount,
    );
    final sharedTotal = expenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.totalAmount);
    final mySharedShare = expenses
        .where((expense) => expense.splitType == SplitType.equal)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final onlyMeTotal = expenses
        .where((expense) => expense.splitType == SplitType.onlyMe)
        .fold<double>(0, (total, expense) => total + expense.shareFor(me.id));
    final assignedToMeTotal = mySharedShare + onlyMeTotal;

    return _DashboardExpenseSummary(
      assignedToMeTotal: assignedToMeTotal,
      sharedTotal: sharedTotal,
      mySharedShare: mySharedShare,
      onlyMeTotal: onlyMeTotal,
      enteredTotal: enteredTotal,
    );
  }
}

class _DashboardExpenseSummary {
  const _DashboardExpenseSummary({
    required this.assignedToMeTotal,
    required this.sharedTotal,
    required this.mySharedShare,
    required this.onlyMeTotal,
    required this.enteredTotal,
  });

  factory _DashboardExpenseSummary.empty() {
    return const _DashboardExpenseSummary(
      assignedToMeTotal: 0,
      sharedTotal: 0,
      mySharedShare: 0,
      onlyMeTotal: 0,
      enteredTotal: 0,
    );
  }

  final double assignedToMeTotal;
  final double sharedTotal;
  final double mySharedShare;
  final double onlyMeTotal;
  final double enteredTotal;
}

class _FinanceSummaryCard extends StatelessWidget {
  const _FinanceSummaryCard({required this.summary});

  final _DashboardExpenseSummary summary;

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
              'Bana yazılan toplam',
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
              'Ortak payım ve sadece bana ait masrafların toplamı.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Ortak masraflar',
              value: _formatAmount(summary.sharedTotal),
            ),
            _SummaryRow(
              label: 'Benim ortak payım',
              value: _formatAmount(summary.mySharedShare),
            ),
            _SummaryRow(
              label: 'Sadece benim masraflarım',
              value: _formatAmount(summary.onlyMeTotal),
            ),
            _SummaryRow(
              label: 'Bu ay girilen toplam',
              value: _formatAmount(summary.enteredTotal),
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
