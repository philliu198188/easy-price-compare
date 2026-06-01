// ============================================================
// Widget 测试：PriceTag 价格标签组件
// ⚠️ 需要 Flutter 环境运行：flutter test test/widgets/price_tag_test.dart
//
// 说明：
// PriceTag 接收 price、originalPrice、size、showSymbol 参数
// - 降价时显示原价删除线
// - 不降价时只显示当前价格
// - 支持 small/medium/large 三种尺寸
// - showSymbol 控制是否显示 ¥ 符号
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_price/widgets/price_tag.dart';

void main() {
  // ───────────────────────────────────────────────
  // 基础渲染测试
  // ───────────────────────────────────────────────
  group('PriceTag — 基础渲染', () {
    testWidgets('显示当前价格', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 99.0),
          ),
        ),
      );

      // 应该渲染包含 "99" 的文本和 "¥" 符号
      expect(find.text('99'), findsOneWidget);
      expect(find.text('¥'), findsOneWidget);
    });

    testWidgets('降价时显示原价删除线', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 79.0, originalPrice: 99.0),
          ),
        ),
      );

      // 应显示当前价格和原价
      expect(find.text('79'), findsOneWidget);
      // 原价会经过 PriceFormatter.format(99.0) → "¥99" 格式化
      // 我们需要查找 "¥99" 文本
      expect(find.text('¥99'), findsOneWidget);
    });

    testWidgets('不降价时不显示原价', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 99.0, originalPrice: 79.0),
          ),
        ),
      );

      // 只显示当前价格，不显示原价（因为 originalPrice < price, 不是降价）
      expect(find.text('99'), findsOneWidget);
      expect(find.text('¥79'), findsNothing);
    });

    testWidgets('originalPrice 为 null 时只显示当前价格', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 59.0),
          ),
        ),
      );

      expect(find.text('59'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // showSymbol 参数
  // ───────────────────────────────────────────────
  group('PriceTag — showSymbol 参数', () {
    testWidgets('showSymbol=true 时显示 ¥ 符号（默认）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 100.0),
          ),
        ),
      );

      expect(find.text('¥'), findsOneWidget);
    });

    testWidgets('showSymbol=false 时不显示 ¥ 符号', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 100.0, showSymbol: false),
          ),
        ),
      );

      expect(find.text('¥'), findsNothing);
    });
  });

  // ───────────────────────────────────────────────
  // 尺寸参数
  // ───────────────────────────────────────────────
  group('PriceTag — size 参数', () {
    testWidgets('small 尺寸正常渲染', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 50.0, size: PriceTagSize.small),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('medium 尺寸正常渲染（默认）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 50.0),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('large 尺寸正常渲染', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceTag(price: 50.0, size: PriceTagSize.large),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // DiscountBadge 测试
  // ───────────────────────────────────────────────
  group('DiscountBadge', () {
    testWidgets('有折扣时显示折扣百分比', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiscountBadge(originalPrice: 100, currentPrice: 79),
          ),
        ),
      );

      // 折扣 = round((1-79/100)*100) = 21
      expect(find.text('-21%'), findsOneWidget);
    });

    testWidgets('无折扣时不显示', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiscountBadge(originalPrice: 100, currentPrice: 100),
          ),
        ),
      );

      // 无折扣时返回 SizedBox.shrink()，不应显示任何折扣文本
      expect(find.text(contains('%')), findsNothing);
    });

    testWidgets('原价 < 现价时不显示（涨价情况）', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiscountBadge(originalPrice: 80, currentPrice: 100),
          ),
        ),
      );

      expect(find.text(contains('%')), findsNothing);
    });
  });
}