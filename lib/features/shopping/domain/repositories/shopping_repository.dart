import '../models/shopping_item.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItem>> getShoppingItems();

  Future<void> addShoppingItem(ShoppingItem item);

  Future<void> togglePurchased(String itemId);

  Future<void> deleteShoppingItem(String itemId);
}
