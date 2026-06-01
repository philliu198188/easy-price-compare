// ============================================================
// 单元测试：Product 和 PricePoint 数据模型
// 运行方式：dart test test/models/product_test.dart
// ============================================================
import 'package:test/test.dart';

// 直接 import 源文件（纯 Dart，无 Flutter 依赖）
import 'package:easy_price/models/product.dart';

void main() {
  // ───────────────────────────────────────────────
  // PricePoint 测试
  // ───────────────────────────────────────────────
  group('PricePoint', () {
    // ---- JSON 序列化 ----
    test('fromJson: 完整字段解析', () {
      final json = {
        'platform': '京东',
        'platformIcon': 'https://img.example.com/jd.png',
        'price': 99.9,
        'originalPrice': 159.0,
        'productUrl': 'https://jd.com/product/123',
      };

      final pp = PricePoint.fromJson(json);

      expect(pp.platform, '京东');
      expect(pp.platformIcon, 'https://img.example.com/jd.png');
      expect(pp.price, 99.9);
      expect(pp.originalPrice, 159.0);
      expect(pp.productUrl, 'https://jd.com/product/123');
    });

    test('fromJson: originalPrice 为 null', () {
      final json = {
        'platform': '淘宝',
        'platformIcon': 'https://img.example.com/tb.png',
        'price': 59.0,
        'productUrl': 'https://taobao.com/item/456',
        // originalPrice 不存在
      };

      final pp = PricePoint.fromJson(json);

      expect(pp.originalPrice, isNull);
      expect(pp.price, 59.0);
      expect(pp.platform, '淘宝');
    });

    test('fromJson: price 为整数时正确转为 double', () {
      final json = {
        'platform': '拼多多',
        'platformIcon': 'https://img.example.com/pdd.png',
        'price': 100,
        'productUrl': 'https://pinduoduo.com/item/789',
      };

      final pp = PricePoint.fromJson(json);

      expect(pp.price, isA<double>());
      expect(pp.price, 100.0);
    });

    test('toJson: 序列化为 Map', () {
      const pp = PricePoint(
        platform: '京东',
        platformIcon: 'jd.png',
        price: 199.0,
        originalPrice: 299.0,
        productUrl: 'https://jd.com/p/1',
      );

      final json = pp.toJson();

      expect(json['platform'], '京东');
      expect(json['price'], 199.0);
      expect(json['originalPrice'], 299.0);
      expect(json['productUrl'], 'https://jd.com/p/1');
    });

    test('toJson: originalPrice 为 null 时不包含该字段', () {
      const pp = PricePoint(
        platform: '淘宝',
        platformIcon: 'tb.png',
        price: 88.0,
        productUrl: 'https://taobao.com/i/2',
      );

      final json = pp.toJson();

      expect(json['originalPrice'], isNull);
      expect(json['price'], 88.0);
    });

    // ---- 业务逻辑 ----
    group('hasDiscount', () {
      test('原价 > 现价 时返回 true', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 79.0,
          originalPrice: 99.0,
          productUrl: 'https://jd.com/p/3',
        );
        expect(pp.hasDiscount, isTrue);
      });

      test('原价 == 现价 时返回 false', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 99.0,
          originalPrice: 99.0,
          productUrl: 'https://jd.com/p/4',
        );
        expect(pp.hasDiscount, isFalse);
      });

      test('原价 < 现价 时返回 false（异常数据）', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 120.0,
          originalPrice: 100.0,
          productUrl: 'https://jd.com/p/5',
        );
        expect(pp.hasDiscount, isFalse);
      });

      test('originalPrice 为 null 时返回 false', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 50.0,
          productUrl: 'https://jd.com/p/6',
        );
        expect(pp.hasDiscount, isFalse);
      });
    });

    group('discountPercent', () {
      test('原价100现价79 → 21% 折扣', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 79.0,
          originalPrice: 100.0,
          productUrl: 'https://jd.com/p/7',
        );
        expect(pp.discountPercent, 21); // (1-79/100)*100 = 21
      });

      test('原价159现价99 → 38% 折扣', () {
        const pp = PricePoint(
          platform: '淘宝',
          platformIcon: 'tb.png',
          price: 99.0,
          originalPrice: 159.0,
          productUrl: 'https://taobao.com/i/8',
        );
        // (1-99/159)*100 ≈ 37.7 → round → 38
        expect(pp.discountPercent, 38);
      });

      test('无折扣时返回 null', () {
        const pp = PricePoint(
          platform: '拼多多',
          platformIcon: 'pdd.png',
          price: 50.0,
          productUrl: 'https://pinduoduo.com/i/9',
        );
        expect(pp.discountPercent, isNull);
      });

      test('原价为0时返回 null（防止除零）', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 50.0,
          originalPrice: 0,
          productUrl: 'https://jd.com/p/10',
        );
        // originalPrice > price 是 false（0 > 50 为假），hasDiscount = false
        // 所以 discountPercent 返回 null
        expect(pp.discountPercent, isNull);
      });

      test('原价等于现价时返回 null', () {
        const pp = PricePoint(
          platform: '京东',
          platformIcon: 'jd.png',
          price: 100.0,
          originalPrice: 100.0,
          productUrl: 'https://jd.com/p/11',
        );
        expect(pp.discountPercent, isNull);
      });
    });
  });

  // ───────────────────────────────────────────────
  // Product 测试
  // ───────────────────────────────────────────────
  group('Product', () {
    // ---- JSON 序列化 ----
    test('fromJson: 完整字段解析（含价格列表）', () {
      final json = {
        'id': 'prod_001',
        'name': 'iPhone 15 Pro Max',
        'imageUrl': 'https://img.example.com/iphone15.png',
        'description': 'Apple 最新旗舰手机',
        'platform': '京东',
        'platformIcon': 'https://img.example.com/jd.png',
        'prices': [
          {
            'platform': '京东',
            'platformIcon': 'jd.png',
            'price': 8999.0,
            'productUrl': 'https://jd.com/iphone15',
          },
          {
            'platform': '淘宝',
            'platformIcon': 'tb.png',
            'price': 8799.0,
            'originalPrice': 8999.0,
            'productUrl': 'https://taobao.com/iphone15',
          },
        ],
      };

      final product = Product.fromJson(json);

      expect(product.id, 'prod_001');
      expect(product.name, 'iPhone 15 Pro Max');
      expect(product.imageUrl, 'https://img.example.com/iphone15.png');
      expect(product.description, 'Apple 最新旗舰手机');
      expect(product.platform, '京东');
      expect(product.prices.length, 2);
      expect(product.prices[0].price, 8999.0);
      expect(product.prices[1].price, 8799.0);
    });

    test('fromJson: 空字段容错', () {
      final json = {
        'id': 'prod_002',
        'name': '某个商品',
        'imageUrl': 'https://img.example.com/product.png',
        // description, platform, platformIcon, prices 均缺失
      };

      final product = Product.fromJson(json);

      expect(product.id, 'prod_002');
      expect(product.description, '');
      expect(product.platform, '');
      expect(product.platformIcon, '');
      expect(product.prices, isEmpty);
    });

    test('fromJson: prices 为 null', () {
      final json = {
        'id': 'prod_003',
        'name': '测试商品',
        'imageUrl': 'https://img.example.com/test.png',
        'prices': null,
      };

      final product = Product.fromJson(json);

      expect(product.prices, isEmpty);
      expect(product.platformCount, 0);
    });

    test('toJson: 序列化为 Map', () {
      const product = Product(
        id: 'prod_004',
        name: 'MacBook Pro 14',
        imageUrl: 'https://img.example.com/mbp14.png',
        description: 'M3 Pro 芯片',
        platform: '京东',
        platformIcon: 'jd.png',
        prices: [
          PricePoint(
            platform: '京东',
            platformIcon: 'jd.png',
            price: 14999.0,
            productUrl: 'https://jd.com/mbp14',
          ),
        ],
      );

      final json = product.toJson();

      expect(json['id'], 'prod_004');
      expect(json['name'], 'MacBook Pro 14');
      expect(json['prices'], isA<List>());
      expect((json['prices'] as List).length, 1);
    });

    // ---- 业务逻辑 ----
    group('minPrice', () {
      test('多个价格中取最小值', () {
        const product = Product(
          id: 'p1',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [
            PricePoint(
              platform: '京东',
              platformIcon: '',
              price: 99.0,
              productUrl: '',
            ),
            PricePoint(
              platform: '淘宝',
              platformIcon: '',
              price: 79.0,
              productUrl: '',
            ),
            PricePoint(
              platform: '拼多多',
              platformIcon: '',
              price: 89.0,
              productUrl: '',
            ),
          ],
        );

        expect(product.minPrice, 79.0);
      });

      test('空价格列表返回 null', () {
        const product = Product(
          id: 'p2',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [],
        );

        expect(product.minPrice, isNull);
      });

      test('单个价格返回该价格', () {
        const product = Product(
          id: 'p3',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [
            PricePoint(
              platform: '京东',
              platformIcon: '',
              price: 50.0,
              productUrl: '',
            ),
          ],
        );

        expect(product.minPrice, 50.0);
      });
    });

    group('maxPrice', () {
      test('多个价格中取最大值', () {
        const product = Product(
          id: 'p4',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [
            PricePoint(
              platform: '京东',
              platformIcon: '',
              price: 99.0,
              productUrl: '',
            ),
            PricePoint(
              platform: '淘宝',
              platformIcon: '',
              price: 159.0,
              productUrl: '',
            ),
            PricePoint(
              platform: '拼多多',
              platformIcon: '',
              price: 129.0,
              productUrl: '',
            ),
          ],
        );

        expect(product.maxPrice, 159.0);
      });

      test('空价格列表返回 null', () {
        const product = Product(
          id: 'p5',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [],
        );

        expect(product.maxPrice, isNull);
      });
    });

    group('platformCount', () {
      test('返回价格条目数', () {
        const product = Product(
          id: 'p6',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
          prices: [
            PricePoint(
              platform: '京东',
              platformIcon: '',
              price: 10.0,
              productUrl: '',
            ),
            PricePoint(
              platform: '淘宝',
              platformIcon: '',
              price: 20.0,
              productUrl: '',
            ),
          ],
        );

        expect(product.platformCount, 2);
      });

      test('空列表返回 0', () {
        const product = Product(
          id: 'p7',
          name: 'Test',
          imageUrl: '',
          description: '',
          platform: '',
          platformIcon: '',
        );
        // 默认 prices = const []
        expect(product.platformCount, 0);
      });
    });
  });
}