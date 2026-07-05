import '../../domain/models/shopping_item.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../data_sources/shopping_local_data_source.dart';

class LocalShoppingRepository implements ShoppingRepository {
  const LocalShoppingRepository(this._dataSource);

  final ShoppingLocalDataSource _dataSource;

  @override
  Future<void> addShoppingItem(ShoppingItem item) {
    return _dataSource.saveShoppingItem(item);
  }

  @override
  Future<void> deleteShoppingItem(String itemId) async {
    final item = await _dataSource.getShoppingItemById(itemId);

    if (item == null) {
      return;
    }

    await _dataSource.saveShoppingItem(item.markedDeleted());
  }

  @override
  Future<List<ShoppingItem>> getShoppingItems() {
    return _dataSource.getShoppingItems();
  }

  @override
  Future<void> togglePurchased(String itemId) async {
    final item = await _dataSource.getShoppingItemById(itemId);

    if (item == null) {
      return;
    }

    await _dataSource.saveShoppingItem(item.toggledPurchased());
  }
}
