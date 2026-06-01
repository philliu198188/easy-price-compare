// ============================================================
// Widget 测试：EmptyState 空状态占位组件
// ⚠️ 需要 Flutter 环境运行：flutter test test/widgets/empty_state_test.dart
//
// 说明：
// EmptyState 显示图标+标题+可选的副标题+可选的操作按钮
// - 默认图标为 Icons.inbox_outlined
// - subtitle 和 actionLabel 为可选参数
// - onAction 决定按钮行为
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_price/widgets/empty_state.dart';

void main() {
  // ───────────────────────────────────────────────
  // 基础渲染测试
  // ───────────────────────────────────────────────
  group('EmptyState — 基础渲染', () {
    testWidgets('显示标题文字', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(title: '暂无数据'),
          ),
        ),
      );

      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('显示默认图标', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(title: '空空如也'),
          ),
        ),
      );

      // 默认图标 Icons.inbox_outlined
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('使用自定义图标', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.search_off_rounded, title: '没找到'),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });
  });

  // ───────────────────────────────────────────────
  // 副标题测试
  // ───────────────────────────────────────────────
  group('EmptyState — 副标题', () {
    testWidgets('有副标题时显示', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: '暂无商品',
              subtitle: '试试其他关键词',
            ),
          ),
        ),
      );

      expect(find.text('试试其他关键词'), findsOneWidget);
    });

    testWidgets('无副标题时不显示', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(title: '空空如也'),
          ),
        ),
      );

      // 不应出现任何副标题相关的内容区域
      // 只有标题文本
      expect(find.text('空空如也'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // 操作按钮测试
  // ───────────────────────────────────────────────
  group('EmptyState — 操作按钮', () {
    testWidgets('有 actionLabel 和 onAction 时显示按钮', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: '出错了',
              actionLabel: '重试',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('重试'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('只有 actionLabel 没有 onAction 时不显示按钮', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: '出错了',
              actionLabel: '重试',
              // onAction 为 null
            ),
          ),
        ),
      );

      // 条件：actionLabel != null && onAction != null
      // 这里 onAction 为 null，按钮不应出现
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('点击按钮触发回调', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: '出错了',
              actionLabel: '重试',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('重试'));
      expect(tapped, isTrue);
    });
  });
}