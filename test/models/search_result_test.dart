// ============================================================
// 单元测试：SearchResult 和 TrendingItem 数据模型
// 运行方式：dart test test/models/search_result_test.dart
// ============================================================
import 'package:test/test.dart';

import 'package:easy_price/models/search_result.dart';

void main() {
  // ───────────────────────────────────────────────
  // SearchResult 测试
  // ───────────────────────────────────────────────
  group('SearchResult', () {
    // ---- JSON 序列化 ----
    test('fromJson: 完整字段解析', () {
      final json = {
        'query': 'iPhone',
        'items': [
          {
            'id': '1',
            'name': 'iPhone 15',
            'imageUrl': 'https://img.example.com/ip15.png',
            'prices': [],
          },
          {
            'id': '2',
            'name': 'iPhone 14',
            'imageUrl': 'https://img.example.com/ip14.png',
            'prices': [],
          },
        ],
        'total': 25,
        'page': 1,
      };

      final result = SearchResult.fromJson(json);

      expect(result.query, 'iPhone');
      expect(result.items.length, 2);
      expect(result.items[0].id, '1');
      expect(result.items[0].name, 'iPhone 15');
      expect(result.total, 25);
      expect(result.page, 1);
    });

    test('fromJson: 空结果', () {
      final json = {
        'query': '不存在的商品',
        'items': [],
        'total': 0,
        'page': 1,
      };

      final result = SearchResult.fromJson(json);

      expect(result.query, '不存在的商品');
      expect(result.items, isEmpty);
      expect(result.total, 0);
    });

    test('toJson: 序列化为 Map', () {
      final result = SearchResult(
        query: 'MacBook',
        items: [],
        total: 10,
        page: 2,
      );

      final json = result.toJson();

      expect(json['query'], 'MacBook');
      expect(json['total'], 10);
      expect(json['page'], 2);
      expect(json['items'], isEmpty);
    });

    test('toJson: 含子项的完整序列化', () {
      final json_input = {
        'query': 'Test',
        'items': [
          {
            'id': '99',
            'name': 'Test Product',
            'imageUrl': 'https://example.com/img.png',
            'prices': [],
          },
        ],
        'total': 1,
        'page': 1,
      };

      final result = SearchResult.fromJson(json_input);
      final json_output = result.toJson();

      expect(json_output['query'], 'Test');
      expect(json_output['total'], 1);
      expect((json_output['items'] as List).length, 1);
    });

    // ---- 业务逻辑 ----
    group('hasMore', () {
      test('items 数量 < total 返回 true', () {
        final json = {
          'query': 'test',
          'items': List.generate(10, (i) => {
            'id': '$i',
            'name': 'Product $i',
            'imageUrl': 'https://img.example.com/p$i.png',
            'prices': [],
          }),
          'total': 50,
          'page': 1,
        };
        final result = SearchResult.fromJson(json);
        expect(result.hasMore, isTrue);
      });

      test('items 数量 == total 返回 false', () {
        final json = {
          'query': 'test',
          'items': List.generate(5, (i) => {
            'id': '$i',
            'name': 'Product $i',
            'imageUrl': 'https://img.example.com/p$i.png',
            'prices': [],
          }),
          'total': 5,
          'page': 1,
        };
        final result = SearchResult.fromJson(json);
        expect(result.hasMore, isFalse);
      });

      test('空结果 total=0 返回 false', () {
        final json = {
          'query': 'nothing',
          'items': [],
          'total': 0,
          'page': 1,
        };
        final result = SearchResult.fromJson(json);
        expect(result.hasMore, isFalse);
      });
    });

    group('isEmpty / isNotEmpty', () {
      test('空列表 isEmpty=true', () {
        const result = SearchResult(
          query: 'empty',
          items: [],
          total: 0,
          page: 1,
        );
        expect(result.isEmpty, isTrue);
        expect(result.isNotEmpty, isFalse);
      });

      test('非空列表 isNotEmpty=true', () {
        final json = {
          'query': 'test',
          'items': [
            {
              'id': '1',
              'name': 'Product',
              'imageUrl': 'https://img.example.com/p.png',
              'prices': [],
            },
          ],
          'total': 1,
          'page': 1,
        };
        final result = SearchResult.fromJson(json);
        expect(result.isEmpty, isFalse);
        expect(result.isNotEmpty, isTrue);
      });
    });
  });

  // ───────────────────────────────────────────────
  // TrendingItem 测试
  // ───────────────────────────────────────────────
  group('TrendingItem', () {
    test('fromJson: 完整字段解析', () {
      final json = {
        'id': 'trend_001',
        'name': '戴森 V15 吸尘器',
        'imageUrl': 'https://img.example.com/dyson.png',
        'platformCount': 5,
        'minPrice': 3299.0,
      };

      final item = TrendingItem.fromJson(json);

      expect(item.id, 'trend_001');
      expect(item.name, '戴森 V15 吸尘器');
      expect(item.imageUrl, 'https://img.example.com/dyson.png');
      expect(item.platformCount, 5);
      expect(item.minPrice, 3299.0);
    });

    test('fromJson: 价格为整数时正确转为 double', () {
      final json = {
        'id': 'trend_002',
        'name': '某商品',
        'imageUrl': 'https://img.example.com/p.png',
        'platformCount': 3,
        'minPrice': 99,
      };

      final item = TrendingItem.fromJson(json);
      expect(item.minPrice, isA<double>());
      expect(item.minPrice, 99.0);
    });

    test('toJson: 序列化为 Map', () {
      const item = TrendingItem(
        id: 'trend_003',
        name: '飞天茅台',
        imageUrl: 'https://img.example.com/mt.png',
        platformCount: 8,
        minPrice: 2899.0,
      );

      final json = item.toJson();

      expect(json['id'], 'trend_003');
      expect(json['name'], '飞天茅台');
      expect(json['platformCount'], 8);
      expect(json['minPrice'], 2899.0);
    });

    test('toJson 与 fromJson 互逆', () {
      const original = TrendingItem(
        id: 'reciprocal_test',
        name: '互逆测试商品',
        imageUrl: 'https://img.example.com/reciprocal.png',
        platformCount: 10,
        minPrice: 1234.56,
      );

      final json = original.toJson();
      final restored = TrendingItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.platformCount, original.platformCount);
      expect(restored.minPrice, original.minPrice);
    });
  });
}