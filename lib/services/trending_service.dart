import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// 热门商品 API 服务
class TrendingService {
  // 热门商品 API — 可通过环境变量/配置切换 baseUrl
  static const String _baseUrl = 'https://api.example.com';

  /// 获取热门商品列表
  static Future<List<Product>> fetchTrending() async {
    try {
      final uri = Uri.parse('$_baseUrl/trending');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((e) => Product.fromJson(e)).toList();
      } else {
        throw HttpException('HTTP ${response.statusCode}');
      }
    } on http.ClientException {
      throw NetworkException('网络连接失败，请检查网络设置');
    } catch (e) {
      if (e is HttpException || e is NetworkException) rethrow;
      throw NetworkException('数据加载失败，请稍后重试');
    }
  }
}

class HttpException implements Exception {
  final String message;
  const HttpException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}