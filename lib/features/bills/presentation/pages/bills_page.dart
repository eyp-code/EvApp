import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _PageHeader(
          title: 'Faturalar',
          subtitle: 'Fatura türleri ve aylık kayıtlar burada yönetilecek.',
        ),
        SizedBox(height: 20),
        SectionPlaceholder(
          title: 'Aylık fatura kayıtları',
          description:
              'Su, elektrik, doğalgaz, kira ve aidat gibi kayıtlar ayrı aylar halinde tutulacak.',
          icon: Icons.payments_outlined,
        ),
      ],
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
      ],
    );
  }
}
