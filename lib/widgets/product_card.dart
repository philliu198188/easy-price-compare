import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/price_formatter.dart';

/// 商品卡片组件 — 用于搜索结果双列瀑布流
class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final double minPrice;
  final double? originalPrice;
  final int platformCount;
  final String? platformLabel;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.minPrice,
    this.originalPrice,
    required this.platformCount,
    this.platformLabel,
    this.onTap,
  });

  /// 是否有降价（原价 > 现价）
  bool get _hasDiscount =>
      originalPrice != null && originalPrice! > minPrice;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 商品图片 16:9 ──
            _buildImage(),
            // ── 商品信息 ──
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 平台标签 Chip
                  if (platformLabel != null && platformLabel!.isNotEmpty) ...[
                    _buildPlatformChip(),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  // 商品名称（最多2行）
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // 价格区域
                  _buildPriceRow(),
                  const SizedBox(height: AppSpacing.xs),
                  // 平台数
                  Text(
                    '$platformCount个平台',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 商品图片（16:9，带缓存和加载占位）
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surface,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  /// 平台标签 Chip
  Widget _buildPlatformChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        platformLabel!,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  /// 价格行（当前价格 + 原价删除线）
  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 当前价格
        Text(
          PriceFormatter.format(minPrice),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _hasDiscount ? AppColors.success : AppColors.price,
            fontFamily: 'PingFang SC',
          ),
        ),
        // 原价删除线（降价时显示）
        if (_hasDiscount) ...[
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              PriceFormatter.format(originalPrice!),
              style: AppTextStyles.originalPrice.copyWith(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}