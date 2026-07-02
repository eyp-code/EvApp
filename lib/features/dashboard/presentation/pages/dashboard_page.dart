import 'package:flutter/material.dart';

import '../../../people/domain/repositories/person_repository.dart';
import '../../../../shared/widgets/section_placeholder.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.personRepository});

  final PersonRepository personRepository;

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      title: 'Ev Özeti',
      subtitle: 'Bu ay evde neler oluyor?',
      children: [
        FutureBuilder(
          future: personRepository.getMe(),
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? 'Ben';

            return SectionPlaceholder(
              title: 'Hoş geldin, $name',
              description:
                  'İlk kişi local veritabanına kaydedildi. Masraf ve fatura kayıtları bu temel üzerine kurulacak.',
              icon: Icons.person_outline,
            );
          },
        ),
        const SectionPlaceholder(
          title: 'Aylık finans özeti',
          description:
              'Toplam ev masrafı, benim payım ve kişisel harcamam burada görünecek.',
          icon: Icons.account_balance_wallet_outlined,
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
