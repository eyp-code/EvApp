import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _PageHeader(
          title: 'Masraflar',
          subtitle: 'Harcama ekleme ve paylaşım hesabı burada başlayacak.',
        ),
        SizedBox(height: 20),
        SectionPlaceholder(
          title: 'Masraf listesi',
          description:
              'İlk MVP’de sadece benim ve ortak eşit böl masrafları eklenecek.',
          icon: Icons.receipt_long_outlined,
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
