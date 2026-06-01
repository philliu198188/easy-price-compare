import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../utils/price_formatter.dart';

/// 价格标签组件 — 常用于列表/卡片中展示价格
class PriceTag extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final PriceTagSize size;
  final bool showSymbol;

  const PriceTag({
    super.key,
    required this.price,
    this.originalPrice,
    this.size = PriceTagSize.medium,
    this.showSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 符号
        if (showSymbol)
          Text(
            '¥',
            style: _symbolStyle,
          ),
        // 价格
        Text(
          PriceFormatter.formatNumber(price),
          style: _priceStyle,
        ),
        // 原价
        if (hasDiscount) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            PriceFormatter.format(originalPrice!),
            style: AppTextStyles.originalPrice.copyWith(
              fontSize: _originalFontSize,
            ),
          ),
        ],
      ],
    );
  }

  TextStyle get _symbolStyle {
    switch (size) {
      case PriceTagSize.small:
        return AppTextStyles.priceMedium.copyWith(fontSize: 12);
      case PriceTagSize.medium:
        return AppTextStyles.priceMedium.copyWith(fontSize: 14);
      case PriceTagSize.large:
        return AppTextStyles.priceLarge.copyWith(fontSize: 18);
    }
  }

  TextStyle get _priceStyle {
    switch (size) {
      case PriceTagSize.small:
        return AppTextStyles.priceMedium.copyWith(fontSize: 16);
      case PriceTagSize.medium:
        return AppTextStyles.priceMedium;
      case PriceTagSize.large:
        return AppTextStyles.priceLarge;
    }
  }

  double get _originalFontSize {
    switch (size) {
      case PriceTagSize.small:
        return 10;
      case PriceTagSize.medium:
        return 12;
      case PriceTagSize.large:
        return 14;
    }
  }
}

enum PriceTagSize { small, medium, large }

/// 折扣标签组件
class DiscountBadge extends StatelessWidget {
  final double originalPrice;
  final double currentPrice;

  const DiscountBadge({
    super.key,
    required this.originalPrice,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (originalPrice <= currentPrice) return const SizedBox.shrink();
    final discount = ((1 - currentPrice / originalPrice) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.price.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        '-$discount%',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.price,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}