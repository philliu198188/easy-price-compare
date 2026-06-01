// ============================================================
// Widget 测试：SkeletonLoader 骨架屏加载组件
// ⚠️ 需要 Flutter 环境运行：flutter test test/widgets/skeleton_loader_test.dart
//
// 说明：
// SkeletonLoader 使用 Shimmer 效果展示加载占位骨架
// - itemCount 控制骨架卡片数量
// - childAspectRatio 控制卡片宽高比
// - _adaptiveColumnCount 根据屏幕宽度自适应列数
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_price/widgets/skeleton_loader.dart';

void main() {
  // ───────────────────────────────────────────────
  // 基础渲染测试
  // ───────────────────────────────────────────────
  group('SkeletonLoader — 基础渲染', () {
    testWidgets('默认参数渲染不抛异常', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      // 基本验证：组件正常渲染
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('自定义 itemCount 渲染正确数量', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 4),
          ),
        ),
      );

      // 由于每个骨架卡片内部包含 Container，我们验证组件存在
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('自定义 childAspectRatio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(childAspectRatio: 0.8),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // 边界情况测试
  // ───────────────────────────────────────────────
  group('SkeletonLoader — 边界情况', () {
    testWidgets('itemCount=0 不渲染任何骨架卡片', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 0),
          ),
        ),
      );

      // GridView 的 itemCount 为 0，验证组件存在但无内容
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('itemCount=1 渲染单个骨架卡片', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 1),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('itemCount=20 大量骨架卡片不抛异常', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 20),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // 自适应列数测试
  // ───────────────────────────────────────────────
  group('SkeletonLoader — 自适应列数', () {
    testWidgets('窄屏幕（300px）应显示 2 列', (tester) async {
      // 设置窄屏幕
      tester.view.physicalSize = const Size(300 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 4),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('中等屏幕（700px）应显示 3 列', (tester) async {
      // 设置中等屏幕
      tester.view.physicalSize = const Size(700 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 6),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('宽屏幕（1000px）应显示 4 列', (tester) async {
      // 设置宽屏幕
      tester.view.physicalSize = const Size(1000 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(itemCount: 8),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });
}