import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'search_provider.dart';

/// 首页 — 搜索入口（增强版：实时建议 Overlay、搜索历史、热门搜索）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final FocusNode _focusNode;
  TabController? _tabController;

  // ── 热门搜索标签颜色池 ──
  static const _tagColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFF22C55E), // green
    Color(0xFF8B5CF6), // purple
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFF59E0B), // amber
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        // 点击空白区域收起键盘
        onTap: () => _focusNode.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            _buildSearchBox(provider),
            Expanded(child: _buildBodyContent(provider)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '易比价',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: false,
      elevation: 0,
    );
  }

  // ── 搜索框 ──
  Widget _buildSearchBox(SearchProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: p.searchController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    p.onItemTap(context, value.trim());
                  }
                },
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: '搜索商品、比价...',
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.textHint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // 清除按钮
            if (p.query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 20),
                onPressed: p.clearQuery,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ── 搜索框下方内容区域 ──
  Widget _buildBodyContent(SearchProvider p) {
    if (p.isSearching) {
      return _buildSuggestionsPanel(p);
    }
    return _buildTabsPanel(p);
  }

  // ═══════════════════════════════════════════
  // 搜索建议面板
  // ═══════════════════════════════════════════
  Widget _buildSuggestionsPanel(SearchProvider p) {
    if (p.isLoading) {
      return _buildShimmerLoading();
    }

    final exactMatches = p.exactMatches;
    final fuzzyMatches = p.fuzzyMatches;

    if (!p.hasSuggestions) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              '未找到「${p.query}」相关商品',
              style: AppTextStyles.body.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 4),
            Text(
              '试试其他关键词',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    // 限制最多 8 条建议
    final displayCount = min(exactMatches.length + fuzzyMatches.length, 8);
    final items = <SearchSuggestion>[];
    items.addAll(exactMatches);
    items.addAll(fuzzyMatches);
    final displayItems = items.take(displayCount).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Material(
        key: const ValueKey('suggestions_panel'),
        color: AppColors.surface,
        elevation: 0,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: displayItems.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return _buildSuggestionItem(
              item,
              onTap: () => p.onItemTap(context, item.text),
            );
          },
        ),
      ),
    );
  }

  /// 单条建议项
  Widget _buildSuggestionItem(SearchSuggestion item, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 精确匹配：蓝色竖线标记
            if (item.isExactMatch) ...[
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
            ] else
              const SizedBox(width: 13),
            // 商品名
            Expanded(
              child: Text(
                item.text,
                style: AppTextStyles.body.copyWith(
                  fontWeight: item.isExactMatch ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // 精确匹配标签
            if (item.isExactMatch)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '精确匹配',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            // 价格信息
            if (item.lowestPrice != null) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${item.lowestPrice!.toStringAsFixed(0)}',
                    style: AppTextStyles.priceMedium.copyWith(fontSize: 14),
                  ),
                  if (item.platform != null)
                    Text(
                      item.platform!,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Shimmer 骨架屏加载态 ──
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 5,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 竖线骨架
              if (i < 2) ...[
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 13),
              // 文字骨架
              Expanded(
                child: Container(
                  height: 14,
                  width: 80 + (i % 3) * 60.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (i < 2)
                Container(
                  height: 14,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 搜索历史 / 热门搜索 Tab 面板
  // ═══════════════════════════════════════════
  Widget _buildTabsPanel(SearchProvider p) {
    return Column(
      children: [
        // Tab 栏
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: '搜索历史'),
              Tab(text: '热门搜索'),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        // Tab 内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(p),
              _buildTrendingTab(p),
            ],
          ),
        ),
      ],
    );
  }

  // ── 搜索历史 Tab ──
  Widget _buildHistoryTab(SearchProvider p) {
    if (p.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.textHint.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('暂无搜索历史', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 清空历史按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近搜索',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('清空搜索历史'),
                      content: const Text('确定要清空所有搜索历史吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            p.clearHistory();
                            Navigator.pop(context);
                          },
                          child: const Text('确定', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.textHint),
              ),
            ],
          ),
        ),
        // 历史列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: p.searchHistory.length,
            itemBuilder: (context, index) {
              final term = p.searchHistory[index];
              return Dismissible(
                key: ValueKey('history_$term'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error.withOpacity(0.8),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                ),
                onDismissed: (_) => p.removeFromHistory(index),
                child: InkWell(
                  onTap: () => p.onItemTap(context, term),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 18, color: AppColors.textHint),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            term,
                            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.north_west_rounded, size: 16, color: AppColors.textHint.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 热门搜索 Tab ──
  Widget _buildTrendingTab(SearchProvider p) {
    if (p.trendingTags.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 48, color: AppColors.textHint.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('热门搜索加载中...', style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                '大家都在搜',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(p.trendingTags.length, (index) {
                  final tag = p.trendingTags[index];
                  final color = _tagColors[index % _tagColors.length];
                  return _buildTrendingChip(tag, color, p);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 热门搜索标签 Chip
  Widget _buildTrendingChip(String label, Color color, SearchProvider p) {
    return GestureDetector(
      onTap: () => p.onItemTap(context, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}