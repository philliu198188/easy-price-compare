import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../services/trending_service.dart';
import '../../utils/platform_utils.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/empty_state.dart';
import '../../services/storage_service.dart';

/// 发现页 — 热门商品 GridView
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<Product>? _products;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final products = await TrendingService.fetchTrending();
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<bool> _isFavorite(String productId) async {
    return StorageService.isFavorite(productId);
  }

  Future<void> _toggleFavorite(Product product) async {
    final isFav = await StorageService.isFavorite(product.id);
    if (isFav) {
      await StorageService.removeFavorite(product.id);
    } else {
      await StorageService.addFavorite(product.id);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '发现',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SkeletonLoader(itemCount: 8);
    }

    if (_error != null) {
      return ErrorRetry(
        message: _error!,
        onRetry: _loadData,
      );
    }

    if (_products == null || _products!.isEmpty) {
      return const EmptyState(
        icon: Icons.local_fire_department_rounded,
        title: '暂无热门商品',
        subtitle: '稍后再来看看吧',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF3B82F6),
      onRefresh: _loadData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _adaptiveColumnCount(constraints.maxWidth);
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: _adaptiveAspectRatio(crossAxisCount),
            ),
            itemCount: _products!.length,
            itemBuilder: (context, index) {
              final product = _products![index];
              return _ProductCard(
                product: product,
                onTap: () => context.go('/detail/${product.id}'),
                onFavorite: () => _toggleFavorite(product),
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
        return 0.78;
      case 3:
        return 0.70;
      default:
        return 0.65;
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  // 收藏按钮
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFavorite,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 20,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 商品信息
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '¥${product.lowestPrice?.toStringAsFixed(2) ?? "--"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '¥${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.platform,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}