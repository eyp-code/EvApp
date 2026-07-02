import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_placeholder.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _PageHeader(
          title: 'Alışveriş',
          subtitle: 'Ev için alınacaklar ve tahmini fiyatlar burada takip edilecek.',
        ),
        SizedBox(height: 20),
        SectionPlaceholder(
          title: 'Alınacaklar listesi',
          description: 'Ürün ekleme, öncelik verme ve alındı işaretleme sonraki fazlarda gelecek.',
          icon: Icons.shopping_cart_outlined,
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
