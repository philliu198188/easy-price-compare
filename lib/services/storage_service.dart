import 'package:shared_preferences/shared_preferences.dart';

/// 本地持久化存储服务
class StorageService {
  static const _favKey = 'favorites';
  static const _historyKey = 'search_history';

  // ---- 收藏 ----

  /// 获取收藏的商品 ID 列表
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favKey) ?? [];
  }

  /// 添加收藏
  static Future<void> addFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favKey) ?? [];
    if (!list.contains(productId)) {
      list.add(productId);
      await prefs.setStringList(_favKey, list);
    }
  }

  /// 移除收藏
  static Future<void> removeFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favKey) ?? [];
    list.remove(productId);
    await prefs.setStringList(_favKey, list);
  }

  /// 检查是否已收藏
  static Future<bool> isFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favKey) ?? [];
    return list.contains(productId);
  }

  // ---- 搜索历史 ----

  /// 获取搜索历史
  static Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  /// 添加搜索历史（去重，最多保留50条）
  static Future<void> addSearchHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > 50) {
      list.removeRange(50, list.length);
    }
    await prefs.setStringList(_historyKey, list);
  }

  /// 清空搜索历史
  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}