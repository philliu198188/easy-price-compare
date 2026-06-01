/// 价格点 — 代表某一平台的价格信息
class PricePoint {
  final String platform;
  final String platformIcon;
  final double price;
  final double? originalPrice;
  final String productUrl;

  const PricePoint({
    required this.platform,
    required this.platformIcon,
    required this.price,
    this.originalPrice,
    required this.productUrl,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      platform: json['platform'] as String,
      platformIcon: json['platformIcon'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      productUrl: json['productUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'platformIcon': platformIcon,
      'price': price,
      'originalPrice': originalPrice,
      'productUrl': productUrl,
    };
  }

  /// 是否有优惠（原价 > 现价）
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 折扣百分比，如 20 表示 8折
  int? get discountPercent {
    if (!hasDiscount || originalPrice == 0) return null;
    return ((1 - price / originalPrice!) * 100).round();
  }
}

/// 商品模型
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String platform;
  final String platformIcon;
  final List<PricePoint> prices;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.platform,
    required this.platformIcon,
    this.prices = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      platformIcon: json['platformIcon'] as String? ?? '',
      prices: (json['prices'] as List<dynamic>?)
              ?.map((e) => PricePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'platform': platform,
      'platformIcon': platformIcon,
      'prices': prices.map((e) => e.toJson()).toList(),
    };
  }

  /// 最低价
  double? get minPrice {
    if (prices.isEmpty) return null;
    return prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  /// 最高价
  double? get maxPrice {
    if (prices.isEmpty) return null;
    return prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  }

  /// 平台数量
  int get platformCount => prices.length;
}