import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../utils/platform_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_loader.dart';

// ============================================================
// 排序枚举
// ============================================================
enum SearchSort {
  /// 综合排序
  relevance('综合', ''),

  /// 价格低 → 高
  priceAsc('价格低→高', 'price_asc'),

  /// 价格高 → 低
  priceDesc('价格高→低', 'price_desc');

  final String label;
  final String apiValue;
  const SearchSort(this.label, this.apiValue);
}

// ============================================================
// 搜索结果页
// ============================================================
class ResultsPage extends StatefulWidget {
  final String? query;

  const ResultsPage({super.key, required this.query});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  // ── Controllers ──
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── API ──
  // TODO: 替换为实际后端地址
  static const _baseUrl = 'http://10.0.2.2:8080';
  late final ApiService _api = ApiService(baseUrl: _baseUrl);

  // ── State ──
  SearchSort _currentSort = SearchSort.relevance;
  final List<_SearchItem> _items = [];
  int _currentPage = 1;
  int _total = 0;

  bool _isFirstLoad = true; // 首次加载 → 骨架屏
  bool _isLoadingMore = false; // 分页加载中
  bool _hasError = false;
  String _errorMessage = '加载失败';

  // ───────────────────────────────────────────────
  // Lifecycle
  // ───────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query ?? '';
    _scrollController.addListener(_onScroll);
    _fetchResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _api.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // 滚动监听 — 上拉加载更多
  // ───────────────────────────────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  // ───────────────────────────────────────────────
  // 数据获取
  // ───────────────────────────────────────────────

  /// 首次搜索 / 切换排序 / 重试
  Future<void> _fetchResults() async {
    if (_isLoadingMore) return;

    setState(() {
      _isFirstLoad = true;
      _hasError = false;
      _currentPage = 1;
      _items.clear();
    });

    try {
      final data = await _api.get('/search', queryParams: {
        'q': _searchController.text.trim(),
        'page': '$_currentPage',
        if (_currentSort.apiValue.isNotEmpty) 'sort': _currentSort.apiValue,
      });

      final List<dynamic> rawItems = data['items'] as List<dynamic>;
      final total = data['total'] as int;

      final items = rawItems.map((e) => _SearchItem.fromJson(e)).toList();

      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _total = total;
        _isFirstLoad = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFirstLoad = false;
        _hasError = true;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  /// 分页加载
  Future<void> _loadMore() async {
    if (_isLoadingMore || _isFirstLoad || _hasError) return;
    if (_items.length >= _total) return; // 已全部加载

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;

    try {
      final data = await _api.get('/search', queryParams: {
        'q': _searchController.text.trim(),
        'page': '$nextPage',
        if (_currentSort.apiValue.isNotEmpty) 'sort': _currentSort.apiValue,
      });

      final List<dynamic> rawItems = data['items'] as List<dynamic>;
      final items = rawItems.map((e) => _SearchItem.fromJson(e)).toList();

      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _items.addAll(items);
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        // 分页失败不阻塞，仅静默忽略
      });
    }
  }

  // ───────────────────────────────────────────────
  // 事件处理
  // ───────────────────────────────────────────────

  void _onSortChanged(SearchSort sort) {
    if (sort == _currentSort) return;
    _currentSort = sort;
    _fetchResults();
  }

  void _onSearchSubmitted(String _) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    // 更新 URL（可选）并重新搜索
    _fetchResults();
  }

  void _onClearSearch() {
    _searchController.clear();
    _fetchResults();
  }

  void _onRetry() {
    _fetchResults();
  }

  // ───────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  /// AppBar — 内嵌搜索框 + 排序下拉
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: _SearchField(
        controller: _searchController,
        onSubmitted: _onSearchSubmitted,
        onClear: _onClearSearch,
      ),
      actions: [
        _SortDropdown(
          currentSort: _currentSort,
          onChanged: _onSortChanged,
        ),
      ],
    );
  }

  /// Body — 根据状态切换
  Widget _buildBody() {
    // 首次加载 → 骨架屏
    if (_isFirstLoad) {
      return const SkeletonLoader(itemCount: 6);
    }

    // 错误状态
    if (_hasError) {
      return ErrorRetry(
        message: _errorMessage,
        onRetry: _onRetry,
      );
    }

    // 空结果
    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: '没找到相关商品',
        subtitle: '试试其他关键词',
      );
    }

    // 正常结果 — 自适应列数 GridView
    return RefreshIndicator(
      onRefresh: _fetchResults,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _adaptiveColumnCount(constraints.maxWidth);
          return GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.ms),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.s,
              mainAxisSpacing: AppSpacing.s,
              childAspectRatio: _adaptiveAspectRatio(crossAxisCount),
            ),
            itemCount: _items.length + (_isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              // 底部加载指示器
              if (index >= _items.length) {
                return const _LoadingCard();
              }

              final item = _items[index];
              return ProductCard(
                id: item.id,
                name: item.name,
                imageUrl: item.imageUrl,
                minPrice: item.minPrice,
                platformCount: item.platformCount,
                platformLabel: item.platformLabel,
                onTap: () => context.push('/detail/${item.id}'),
              );
            },
          );
        },
      ),
    );
  }

  /// 自适应列数：手机 2 列，平板/横屏 3 列，大屏 4 列
  int _adaptiveColumnCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  /// 自适应宽高比：列数越多，卡片越扁
  double _adaptiveAspectRatio(int columns) {
    switch (columns) {
      case 4:
        return 0.75;
      case 3:
        return 0.68;
      default:
        return 0.62;
    }
  }

  // ───────────────────────────────────────────────
  // 错误信息友好化
  // ───────────────────────────────────────────────
  String _friendlyError(Object e) {
    if (e is ApiException) return e.message;
    if (e is TimeoutException) return '请求超时，请检查网络';
    return '网络连接失败，请检查网络';
  }
}

// ============================================================
// AppBar 内嵌搜索框
// ============================================================
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        style: AppTextStyles.body.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: '搜索商品、比价...',
          hintStyle: AppTextStyles.bodySecondary,
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textHint,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ============================================================
// 排序下拉按钮
// ============================================================
class _SortDropdown extends StatelessWidget {
  final SearchSort currentSort;
  final ValueChanged<SearchSort> onChanged;

  const _SortDropdown({
    required this.currentSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SearchSort>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      onSelected: onChanged,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentSort.label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down_rounded, size: 18),
        ],
      ),
      itemBuilder: (context) {
        return SearchSort.values.map((sort) {
          final isSelected = sort == currentSort;
          return PopupMenuItem<SearchSort>(
            value: sort,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sort.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

// ============================================================
// 分页加载底部占位卡片
// ============================================================
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 搜索结果项（轻量数据模型）
// ============================================================
class _SearchItem {
  final String id;
  final String name;
  final String imageUrl;
  final double minPrice;
  final int platformCount;
  final String? platformLabel;

  const _SearchItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.minPrice,
    required this.platformCount,
    this.platformLabel,
  });

  factory _SearchItem.fromJson(Map<String, dynamic> json) {
    return _SearchItem(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0,
      platformCount: json['platformCount'] as int? ?? 0,
      platformLabel: json['platformLabel'] as String?,
    );
  }
}