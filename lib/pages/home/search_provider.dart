import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/storage_service.dart';
import '../../services/trending_service.dart';

/// 搜索建议模型
class SearchSuggestion {
  final String text;
  final bool isExactMatch;
  final double? lowestPrice;
  final String? platform;

  const SearchSuggestion({
    required this.text,
    this.isExactMatch = false,
    this.lowestPrice,
    this.platform,
  });
}

/// 首页搜索状态管理
class SearchProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  String _query = '';
  List<SearchSuggestion> _suggestions = [];
  List<String> _searchHistory = [];
  List<String> _trendingTags = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Getters
  String get query => _query;
  List<SearchSuggestion> get suggestions => _suggestions;
  List<SearchSuggestion> get exactMatches =>
      _suggestions.where((s) => s.isExactMatch).toList();
  List<SearchSuggestion> get fuzzyMatches =>
      _suggestions.where((s) => !s.isExactMatch).toList();
  List<String> get searchHistory => _searchHistory;
  List<String> get trendingTags => _trendingTags;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  SearchProvider() {
    searchController.addListener(_onQueryChanged);
    _loadInitialData();
  }

  void _loadInitialData() {
    _fetchTrending();
    _loadHistory();
  }

  // ─── 加载搜索历史 (从 SharedPreferences 持久化读取) ───
  Future<void> _loadHistory() async {
    try {
      _searchHistory = await StorageService.getSearchHistory();
    } catch (_) {
      // 首次启动或无数据时使用空列表
      _searchHistory = [];
    }
    notifyListeners();
  }

  void _onQueryChanged() {
    final text = searchController.text.trim();
    _query = text;
    _isSearching = text.isNotEmpty;
    notifyListeners();

    if (text.isEmpty) {
      _suggestions = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Debounce 300ms
    _debounceTimer?.cancel();
    _isLoading = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(text);
    });
  }

  // ─── 搜索建议 (模拟 API 调用) ───
  Future<void> _fetchSuggestions(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    // 模拟搜索结果
    final allResults = <SearchSuggestion>[];

    // 精确匹配模拟数据
    final exactKeywords = [
      'iPhone 15',
      'iPhone 15 Pro',
      'MacBook Pro 14',
      'MacBook Air M3',
      'AirPods Pro 2',
      'iPad Air',
      'Apple Watch',
      '索尼 WH-1000XM5',
      '戴森 V15',
      'Nike Air Force 1',
    ];

    for (final item in exactKeywords) {
      if (item.toLowerCase().contains(keyword.toLowerCase())) {
        allResults.add(SearchSuggestion(
          text: item,
          isExactMatch: true,
          lowestPrice: 599.0 + Random().nextDouble() * 3000,
          platform: ['京东', '淘宝', '拼多多'][Random().nextInt(3)],
        ));
      }
    }

    // 模糊匹配模拟数据
    final fuzzyKeywords = [
      '手机壳 $keyword',
      '$keyword 充电器',
      '$keyword 保护膜',
      '$keyword 数据线',
      '无线$keyword',
      '二手$keyword',
      '$keyword 配件',
      '$keyword 套装',
    ];

    for (final item in fuzzyKeywords) {
      allResults.add(SearchSuggestion(
        text: item,
        isExactMatch: false,
        lowestPrice: 19.9 + Random().nextDouble() * 200,
        platform: ['京东', '淘宝', '拼多多'][Random().nextInt(3)],
      ));
    }

    _suggestions = allResults;
    _isLoading = false;
    notifyListeners();
  }

  // ─── 热门搜索 ───
  Future<void> _fetchTrending() async {
    try {
      final products = await TrendingService.fetchTrending();
      if (products.isNotEmpty) {
        _trendingTags = products.map((p) => p.name).toList();
        notifyListeners();
        return;
      }
    } catch (_) {
      // API 不可用时使用本地模拟数据
    }
    // 本地回退数据
    _trendingTags = [
      'iPhone 15 Pro Max',
      '华为 Mate 60',
      '戴森吸尘器',
      '飞天茅台',
      'Nike Dunk',
      'AirPods Pro',
      'PS5',
      'Switch OLED',
      'SK-II 神仙水',
      '乐高兰博基尼',
      'iPad Pro M4',
      '索尼降噪耳机',
    ];
    notifyListeners();
  }

  // ─── 搜索历史操作 ───
  void addToHistory(String term) {
    if (term.isEmpty) return;
    _searchHistory.remove(term);
    _searchHistory.insert(0, term);
    // 保留最近 50 条
    if (_searchHistory.length > 50) {
      _searchHistory = _searchHistory.sublist(0, 50);
    }
    notifyListeners();
    _saveHistoryToPrefs();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _searchHistory.length) {
      _searchHistory.removeAt(index);
      notifyListeners();
      _saveHistoryToPrefs();
    }
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
    StorageService.clearSearchHistory();
  }

  /// 持久化搜索历史到 SharedPreferences
  Future<void> _saveHistoryToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
    } catch (_) {
      // 静默失败
    }
  }

  // ─── 选中建议/历史/热门项 ───
  void onItemTap(BuildContext context, String term) {
    addToHistory(term);
    searchController.clear();
    _query = '';
    _suggestions = [];
    _isSearching = false;
    notifyListeners();

    // 使用 GoRouter 导航
    GoRouter.of(context).go('/results?q=${Uri.encodeComponent(term)}');
  }

  void clearQuery() {
    searchController.clear();
    _query = '';
    _suggestions = [];
    _isSearching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onQueryChanged);
    searchController.dispose();
    super.dispose();
  }
}