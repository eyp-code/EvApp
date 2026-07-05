import 'package:flutter/material.dart';

import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';

enum _ShoppingFilter { all, pending, purchased }

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key, required this.shoppingRepository});

  final ShoppingRepository shoppingRepository;

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late Future<List<ShoppingItem>> _itemsFuture;
  _ShoppingFilter _filter = _ShoppingFilter.all;

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
          title: 'Alisveris',
          subtitle:
              'Ev icin alinacaklari takip et ve satin alindiginda isaretle.',
          onAddPressed: _addItem,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<ShoppingItem>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <ShoppingItem>[];
            final filteredItems = _applyFilter(items);

            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }

            if (items.isEmpty) {
              return _EmptyShoppingCard(onAddPressed: _addItem);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShoppingSummaryCard(items: items),
                const SizedBox(height: 16),
                _ShoppingFilterBar(
                  selectedFilter: _filter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _filter = filter;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (filteredItems.isEmpty)
                  const _NoItemsForFilterCard()
                else
                  ...filteredItems.map(
                    (item) => _ShoppingItemCard(
                      item: item,
                      onTogglePurchased: () => _togglePurchased(item),
                      onDelete: () => _deleteItem(item),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<ShoppingItem> _applyFilter(List<ShoppingItem> items) {
    switch (_filter) {
      case _ShoppingFilter.all:
        return items;
      case _ShoppingFilter.pending:
        return items.where((item) => !item.isPurchased).toList();
      case _ShoppingFilter.purchased:
        return items.where((item) => item.isPurchased).toList();
    }
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
  String _category = 'Market';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      ShoppingItem.create(
        name: _nameController.text.trim(),
        category: _category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Urun ekle'),
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
                decoration: const InputDecoration(labelText: 'Urun adi'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Urun adi gerekli';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
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
                  DropdownMenuItem(value: 'Diger', child: Text('Diger')),
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgec'),
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
                    item.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Urunu sil',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingSummaryCard extends StatelessWidget {
  const _ShoppingSummaryCard({required this.items});

  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    final pendingItems = items.where((item) => !item.isPurchased).toList();
    final purchasedItems = items.where((item) => item.isPurchased).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: 'Toplam urun',
                value: '${items.length}',
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: 'Alinacak',
                value: '${pendingItems.length}',
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: 'Alindi',
                value: '${purchasedItems.length}',
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: 'Durum',
                value: pendingItems.isEmpty ? 'Tamam' : 'Bekliyor',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _ShoppingFilterBar extends StatelessWidget {
  const _ShoppingFilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _ShoppingFilter selectedFilter;
  final ValueChanged<_ShoppingFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ShoppingFilter>(
      segments: const [
        ButtonSegment<_ShoppingFilter>(
          value: _ShoppingFilter.all,
          label: Text('Tumu'),
        ),
        ButtonSegment<_ShoppingFilter>(
          value: _ShoppingFilter.pending,
          label: Text('Alinacak'),
        ),
        ButtonSegment<_ShoppingFilter>(
          value: _ShoppingFilter.purchased,
          label: Text('Alindi'),
        ),
      ],
      selected: {selectedFilter},
      onSelectionChanged: (selection) {
        onFilterChanged(selection.first);
      },
    );
  }
}

class _NoItemsForFilterCard extends StatelessWidget {
  const _NoItemsForFilterCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Bu filtrede gosterilecek urun yok.',
          style: Theme.of(context).textTheme.bodyMedium,
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
                    'Henuz urun yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ilk urunu ekleyerek alisveris listesini olusturmaya basla.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Urun ekle'),
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
          tooltip: 'Urun ekle',
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
