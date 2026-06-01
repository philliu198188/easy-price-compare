/// 价格格式化工具
class PriceFormatter {
  PriceFormatter._();

  /// 格式化价格为 ¥1,299
  ///
  /// [price] 价格数值
  /// [showDecimal] 是否显示小数位（默认false，只显示整数）
  ///
  /// 示例：
  /// ```dart
  /// PriceFormatter.format(1299)   → "¥1,299"
  /// PriceFormatter.format(299.9)  → "¥299"
  /// PriceFormatter.format(299.9, showDecimal: true) → "¥299.90"
  /// ```
  static String format(double price, {bool showDecimal = false}) {
    if (price >= 1000 || price == price.roundToDouble()) {
      final integerPart = price.round();
      final formatted = _formatInteger(integerPart);
      return '¥$formatted';
    }

    if (showDecimal) {
      final decimalStr = price.toStringAsFixed(2);
      final parts = decimalStr.split('.');
      final formattedInt = _formatInteger(int.parse(parts[0]));
      return '¥$formattedInt.${parts[1]}';
    }

    // 小于 1000 的非整数，显示1位小数
    if (price != price.roundToDouble()) {
      return '¥${price.toStringAsFixed(1)}';
    }

    return '¥${price.round()}';
  }

  /// 仅格式化数字部分（不含 ¥ 符号）
  static String formatNumber(double price) {
    final s = format(price);
    return s.substring(1); // 去掉 ¥ 前缀
  }

  /// 格式化千分位
  static String _formatInteger(int n) {
    if (n < 0) return '-${_formatInteger(-n)}';
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  /// 格式化价格区间
  ///
  /// 示例: formatRange(99, 159) → "¥99 - ¥159"
  static String formatRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) return format(minPrice);
    return '${format(minPrice)} - ${format(maxPrice)}';
  }

  /// 格式化折扣信息
  ///
  /// 示例: formatDiscount(100, 79) → "¥79 (7.9折)"
  static String formatDiscount(double original, double current) {
    final discount = (current / original * 10).toStringAsFixed(1);
    return '${format(current)} (${discount}折)';
  }
}