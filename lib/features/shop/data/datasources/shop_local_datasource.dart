import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ShopLocalDataSource {
  Future<void> cacheCategories(List<Map<String, dynamic>> data);
  Future<List<Map<String, dynamic>>?> getCachedCategories();
}

class ShopLocalDataSourceImpl implements ShopLocalDataSource {
  final List<Map<String, dynamic>> _cache = [];

  @override
  Future<void> cacheCategories(List<Map<String, dynamic>> data) async {
    _cache
      ..clear()
      ..addAll(data);
  }

  @override
  Future<List<Map<String, dynamic>>?> getCachedCategories() async {
    return _cache.isEmpty ? null : List.from(_cache);
  }
}

final shopLocalDataSourceProvider = Provider<ShopLocalDataSource>(
  (_) => ShopLocalDataSourceImpl(),
);
