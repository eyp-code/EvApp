import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PageLayout(
      title: 'Ev Özeti',
      subtitle: 'Bu ay evde neler oluyor?',
      children: [
        SectionPlaceholder(
          title: 'Aylık finans özeti',
          description: 'Toplam ev masrafı, benim payım ve net borç burada görünecek.',
          icon: Icons.account_balance_wallet_outlined,
        ),
        SectionPlaceholder(
          title: 'Bekleyen işler',
          description: 'Girilmemiş faturalar, yaklaşan abonelikler ve görevler burada toplanacak.',
          icon: Icons.notifications_active_outlined,
        ),
      ],
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
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }
}
