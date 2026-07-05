import 'package:hive/hive.dart';

import '../../domain/models/shopping_item.dart';

class ShoppingLocalDataSource {
  const ShoppingLocalDataSource(this._box);

  final Box<Map> _box;

  Future<List<ShoppingItem>> getShoppingItems() async {
    final items = _box.values
        .map((value) => ShoppingItem.fromJson(Map<String, dynamic>.from(value)))
        .where((item) => !item.isDeleted)
        .toList();

    items.sort((first, second) {
      if (first.isPurchased != second.isPurchased) {
        return first.isPurchased ? 1 : -1;
      }

      return second.createdAt.compareTo(first.createdAt);
    });

    return items;
  }

  Future<ShoppingItem?> getShoppingItemById(String id) async {
    final value = _box.get(id);

    if (value == null) {
      return null;
    }

    return ShoppingItem.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> saveShoppingItem(ShoppingItem item) async {
    await _box.put(item.id, item.toJson());
  }
}
