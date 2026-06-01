// ============================================================
// 单元测试：StorageService 本地持久化存储服务
// ⚠️ 需要 Flutter 环境运行：flutter test test/services/storage_service_test.dart
//
// 说明：
// - StorageService 依赖 SharedPreferences（Flutter 插件）
// - 测试中可使用 SharedPreferences.setMockInitialValues 进行模拟
// - 测试覆盖：收藏增删查、搜索历史增删清空
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_price/services/storage_service.dart';

void main() {
  // 在每个测试前重置 SharedPreferences 模拟数据
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ───────────────────────────────────────────────
  // 收藏功能测试
  // ───────────────────────────────────────────────
  group('StorageService — 收藏功能', () {
    test('初始收藏列表为空', () async {
      final favorites = await StorageService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('添加收藏后可以获取', () async {
      await StorageService.addFavorite('product_001');
      final favorites = await StorageService.getFavorites();

      expect(favorites.length, 1);
      expect(favorites, contains('product_001'));
    });

    test('重复添加同一商品不会产生重复', () async {
      await StorageService.addFavorite('product_001');
      await StorageService.addFavorite('product_001');
      await StorageService.addFavorite('product_001');

      final favorites = await StorageService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0], 'product_001');
    });

    test('添加多个不同收藏', () async {
      await StorageService.addFavorite('product_001');
      await StorageService.addFavorite('product_002');
      await StorageService.addFavorite('product_003');

      final favorites = await StorageService.getFavorites();
      expect(favorites.length, 3);
      expect(favorites, containsAll(['product_001', 'product_002', 'product_003']));
    });

    test('移除收藏', () async {
      await StorageService.addFavorite('product_001');
      await StorageService.addFavorite('product_002');
      await StorageService.removeFavorite('product_001');

      final favorites = await StorageService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites, contains('product_002'));
      expect(favorites, isNot(contains('product_001')));
    });

    test('移除不存在的收藏不会报错', () async {
      await StorageService.addFavorite('product_001');
      await StorageService.removeFavorite('nonexistent');

      final favorites = await StorageService.getFavorites();
      expect(favorites.length, 1);
      expect(favorites[0], 'product_001');
    });

    test('isFavorite 正确检测收藏状态', () async {
      expect(await StorageService.isFavorite('product_001'), isFalse);

      await StorageService.addFavorite('product_001');
      expect(await StorageService.isFavorite('product_001'), isTrue);

      await StorageService.removeFavorite('product_001');
      expect(await StorageService.isFavorite('product_001'), isFalse);
    });
  });

  // ───────────────────────────────────────────────
  // 搜索历史功能测试
  // ───────────────────────────────────────────────
  group('StorageService — 搜索历史', () {
    test('初始搜索历史为空', () async {
      final history = await StorageService.getSearchHistory();
      expect(history, isEmpty);
    });

    test('添加搜索历史', () async {
      await StorageService.addSearchHistory('iPhone');
      final history = await StorageService.getSearchHistory();

      expect(history.length, 1);
      expect(history[0], 'iPhone');
    });

    test('重复搜索词移到最前面（去重）', () async {
      await StorageService.addSearchHistory('iPhone');
      await StorageService.addSearchHistory('MacBook');
      await StorageService.addSearchHistory('iPhone'); // 重复搜索

      final history = await StorageService.getSearchHistory();

      expect(history.length, 2);
      expect(history[0], 'iPhone'); // 最新的在最前面
      expect(history[1], 'MacBook');
    });

    test('多次添加后保持正确顺序', () async {
      await StorageService.addSearchHistory('A');
      await StorageService.addSearchHistory('B');
      await StorageService.addSearchHistory('C');

      final history = await StorageService.getSearchHistory();
      expect(history, ['C', 'B', 'A']);
    });

    test('重复搜索 B：B 移到最前', () async {
      await StorageService.addSearchHistory('A');
      await StorageService.addSearchHistory('B');
      await StorageService.addSearchHistory('C');
      await StorageService.addSearchHistory('B');

      final history = await StorageService.getSearchHistory();
      expect(history, ['B', 'C', 'A']);
    });

    test('最多保留 50 条历史', () async {
      // 添加 60 条搜索历史
      for (int i = 0; i < 60; i++) {
        await StorageService.addSearchHistory('keyword_$i');
      }

      final history = await StorageService.getSearchHistory();
      expect(history.length, 50);

      // 最新添加的保留（keyword_59 在第一条）
      expect(history[0], 'keyword_59');
    });

    test('清空搜索历史', () async {
      await StorageService.addSearchHistory('iPhone');
      await StorageService.addSearchHistory('MacBook');

      expect((await StorageService.getSearchHistory()).length, 2);

      await StorageService.clearSearchHistory();

      final historyAfterClear = await StorageService.getSearchHistory();
      expect(historyAfterClear, isEmpty);
    });

    test('清空已空的历史不会报错', () async {
      await StorageService.clearSearchHistory();
      final history = await StorageService.getSearchHistory();
      expect(history, isEmpty);
    });
  });

  // ───────────────────────────────────────────────
  // 数据隔离测试
  // ───────────────────────────────────────────────
  group('StorageService — 数据隔离', () {
    test('收藏和历史数据互不干扰', () async {
      await StorageService.addFavorite('fav_1');
      await StorageService.addSearchHistory('search_1');

      final favorites = await StorageService.getFavorites();
      final history = await StorageService.getSearchHistory();

      // 收藏列表不应包含搜索历史
      expect(favorites, isNot(contains('search_1')));
      // 搜索历史不应包含收藏
      expect(history, isNot(contains('fav_1')));
    });
  });
}