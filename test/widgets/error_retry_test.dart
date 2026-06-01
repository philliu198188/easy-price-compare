// ============================================================
// Widget 测试：ErrorRetry 错误重试组件
// ⚠️ 需要 Flutter 环境运行：flutter test test/widgets/error_retry_test.dart
//
// 说明：
// ErrorRetry 显示错误信息 + 重试按钮
// - message 参数为错误描述
// - onRetry 为点击重试按钮的回调
// - 默认显示 wifi_off_rounded 图标和"重试"按钮
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_price/widgets/error_retry.dart';

void main() {
  // ───────────────────────────────────────────────
  // 基础渲染测试
  // ───────────────────────────────────────────────
  group('ErrorRetry — 基础渲染', () {
    testWidgets('显示错误消息文本', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '网络连接失败，请检查网络',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('网络连接失败，请检查网络'), findsOneWidget);
    });

    testWidgets('显示重试按钮', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '加载失败',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('重试'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('显示错误图标', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '加载失败',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────
  // 交互测试
  // ───────────────────────────────────────────────
  group('ErrorRetry — 交互', () {
    testWidgets('点击重试按钮触发 onRetry 回调', (tester) async {
      int retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '网络异常',
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      // 点击重试按钮
      await tester.tap(find.text('重试'));
      expect(retryCount, 1);

      // 再次点击
      await tester.tap(find.text('重试'));
      expect(retryCount, 2);
    });

    testWidgets('多次点击重试正常工作', (tester) async {
      int count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '超时',
              onRetry: () => count++,
            ),
          ),
        ),
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('重试'));
      }
      expect(count, 5);
    });
  });

  // ───────────────────────────────────────────────
  // 不同消息内容测试
  // ───────────────────────────────────────────────
  group('ErrorRetry — 消息内容', () {
    testWidgets('短消息正常显示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: '出错了',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('出错了'), findsOneWidget);
    });

    testWidgets('长消息正常显示', (tester) async {
      const longMsg = '服务器繁忙，请稍后重试。如多次出现此问题，请检查网络连接或联系客服获取帮助。';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorRetry(
              message: longMsg,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text(longMsg), findsOneWidget);
    });
  });
}