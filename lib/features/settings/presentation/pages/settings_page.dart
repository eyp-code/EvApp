import 'package:flutter/material.dart';

import '../../../people/domain/repositories/person_repository.dart';
import '../../../../shared/widgets/section_placeholder.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.personRepository});

  final PersonRepository personRepository;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _PageHeader(
          title: 'Ayarlar',
          subtitle: 'Para birimi, bildirimler ve yedekleme burada yönetilecek.',
        ),
        const SizedBox(height: 20),
        FutureBuilder(
          future: personRepository.getPersons(),
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;

            return SectionPlaceholder(
              title: 'Local kayıt durumu',
              description: 'Hive içinde şu an $count kişi kaydı var.',
              icon: Icons.storage_outlined,
            );
          },
        ),
        const SectionPlaceholder(
          title: 'Uygulama ayarları',
          description:
              'JSON yedek alma, içe aktarma ve bildirim ayarları bu ekrana eklenecek.',
          icon: Icons.settings_outlined,
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
