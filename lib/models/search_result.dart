import 'product.dart';

/// 搜索结果模型
class SearchResult {
  final String query;
  final List<Product> items;
  final int total;
  final int page;

  const SearchResult({
    required this.query,
    required this.items,
    required this.total,
    required this.page,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      query: json['query'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
    };
  }

  /// 是否有更多页
  bool get hasMore => items.length < total;

  /// 是否为空
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// 热门搜索 / 趋势商品
class TrendingItem {
  final String id;
  final String name;
  final String imageUrl;
  final int platformCount;
  final double minPrice;

  const TrendingItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.platformCount,
    required this.minPrice,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      platformCount: json['platformCount'] as int,
      minPrice: (json['minPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'platformCount': platformCount,
      'minPrice': minPrice,
    };
  }
}