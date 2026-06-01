import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../utils/price_formatter.dart';

class DetailPage extends StatelessWidget {
  final String productId;

  const DetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: 分享
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 收藏
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 商品图片区域
              _buildImageSection(),
              // 商品信息
              _buildInfoSection(),
              // 比价列表
              _buildPriceComparison(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 280,
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined,
                size: 80, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.m),
            Text(
              '商品ID: $productId',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '图片加载中...',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '商品名称',
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: AppSpacing.ms),
          Row(
            children: [
              Text(
                PriceFormatter.format(99.0),
                style: AppTextStyles.priceLarge,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                PriceFormatter.format(159.0),
                style: AppTextStyles.originalPrice,
              ),
              const SizedBox(width: AppSpacing.s),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.price.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '6.2折',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.price,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('全平台比价', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.m),
          // 占位：价格列表
          ...List.generate(3, (index) => _buildPriceItem(
                platform: ['京东', '淘宝', '拼多多'][index],
                price: [99.0, 109.0, 129.0][index],
                originalPrice: [159.0, 139.0, 129.0][index],
                url: 'https://example.com/$index',
              )),
        ],
      ),
    );
  }

  Widget _buildPriceItem({
    required String platform,
    required double price,
    required double originalPrice,
    required String url,
  }) {
    final hasDiscount = price < originalPrice;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.ms),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 平台图标（占位）
          Container(
            width: AppSpacing.iconL,
            height: AppSpacing.iconL,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: const Icon(Icons.store,
                size: 20, color: AppColors.textHint),
          ),
          const SizedBox(width: AppSpacing.ms),
          // 平台名称
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platform, style: AppTextStyles.subtitle),
                if (hasDiscount) ...[
                  const SizedBox(height: 2),
                  Text(
                    PriceFormatter.format(originalPrice),
                    style: AppTextStyles.originalPrice,
                  ),
                ],
              ],
            ),
          ),
          // 价格
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PriceFormatter.format(price),
                style: AppTextStyles.priceMedium,
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 2),
                Text(
                  '立省¥${(originalPrice - price).round()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: AppSpacing.s),
          // 购买按钮
          SizedBox(
            height: AppSpacing.tapTarget - 8,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 打开链接
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.ms),
              ),
              child: const Text('去购买'),
            ),
          ),
        ],
      ),
    );
  }
}