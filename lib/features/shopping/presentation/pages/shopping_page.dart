import 'package:flutter/material.dart';

import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.shoppingRepository});

  final ShoppingRepository shoppingRepository;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late Future<List<ShoppingItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _itemsFuture = widget.shoppingRepository.getShoppingItems();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _itemsFuture;
  }

  Future<void> _addItem() async {
    final item = await showDialog<ShoppingItem>(
      context: context,
      builder: (context) => const _AddShoppingItemDialog(),
    );

    if (item == null) {
      return;
    }

    await widget.shoppingRepository.addShoppingItem(item);
    await _refresh();
  }

  Future<void> _togglePurchased(ShoppingItem item) async {
    await widget.shoppingRepository.togglePurchased(item.id);
    await _refresh();
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    await widget.shoppingRepository.deleteShoppingItem(item.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PageHeader(
          title: 'Alışveriş',
          subtitle:
              'Ev için alınacakları takip et ve satın alındı olarak işaretle.',
          onAddPressed: _addItem,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<ShoppingItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <ShoppingItem>[];

            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            if (items.isEmpty) {
              return _EmptyShoppingCard(onAddPressed: _addItem);
            }

            return Column(
              children: items
                  .map(
                    (item) => _ShoppingItemCard(
                      item: item,
                      onTogglePurchased: () => _togglePurchased(item),
                      onDelete: () => _deleteItem(item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AddShoppingItemDialog extends StatefulWidget {
  const _AddShoppingItemDialog();

  @override
  State<_AddShoppingItemDialog> createState() => _AddShoppingItemDialogState();
}

class _AddShoppingItemDialogState extends State<_AddShoppingItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Market';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final estimatedPrice = priceText.isEmpty ? null : double.parse(priceText);

    Navigator.of(context).pop(
      ShoppingItem.create(
        name: _nameController.text.trim(),
        category: _category,
        estimatedPrice: estimatedPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ürün ekle'),
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
                decoration: const InputDecoration(labelText: 'Ürün adı'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ürün adı gerekli';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'Market', child: Text('Market')),
                  DropdownMenuItem(value: 'Temizlik', child: Text('Temizlik')),
                  DropdownMenuItem(value: 'Mutfak', child: Text('Mutfak')),
                  DropdownMenuItem(value: 'Banyo', child: Text('Banyo')),
                  DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _category = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tahmini fiyat',
                  helperText: 'İsteğe bağlı',
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  final priceText = (value ?? '').trim().replaceAll(',', '.');
                  if (priceText.isEmpty) {
                    return null;
                  }

                  final price = double.tryParse(priceText);
                  if (price == null || price <= 0) {
                    return 'Geçerli bir fiyat gir';
                  }

                  return null;
                },
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

class _ShoppingItemCard extends StatelessWidget {
  const _ShoppingItemCard({
    required this.item,
    required this.onTogglePurchased,
    required this.onDelete,
  });

  final ShoppingItem item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: item.isPurchased,
              onChanged: (_) => onTogglePurchased(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Icon(
              item.isPurchased
                  ? Icons.check_circle_outline
                  : Icons.shopping_cart_outlined,
              color: item.isPurchased ? Colors.green : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: item.isPurchased
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.estimatedPrice == null
                        ? item.category
                        : '${item.category} • ${item.estimatedPrice!.toStringAsFixed(2)} TL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Ürünü sil',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShoppingCard extends StatelessWidget {
  const _EmptyShoppingCard({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shopping_cart_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Henüz ürün yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İlk ürünü ekleyerek alışveriş listesini oluşturmaya başla.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Ürün ekle'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.onAddPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAddPressed;

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
        IconButton.filled(
          tooltip: 'Ürün ekle',
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
