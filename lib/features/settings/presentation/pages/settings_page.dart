import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _PageHeader(
          title: 'Ayarlar',
          subtitle: 'Para birimi, bildirimler ve yedekleme burada yönetilecek.',
        ),
        SizedBox(height: 20),
        SectionPlaceholder(
          title: 'Uygulama ayarları',
          description: 'JSON yedek alma, içe aktarma ve bildirim ayarları bu ekrana eklenecek.',
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
