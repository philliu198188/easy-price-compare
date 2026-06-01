// ============================================================
// 单元测试：PlatformUtils 平台检测工具
// ⚠️ 需要 Flutter 环境运行：flutter test test/utils/platform_utils_test.dart
//
// 说明：
// - PlatformUtils 依赖 dart:io 和 package:flutter/foundation.dart
// - isOhos/isAndroid/isIOS 等方法的返回值依赖运行时环境
// - 在 Linux 环境下 isAndroid/isIOS 返回 false
// - 部分静态方法可在纯 Dart 中测试逻辑（isMobile/isLargeScreen 等组合逻辑）
// ============================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:easy_price/utils/platform_utils.dart';

void main() {
  group('PlatformUtils — 运行时平台检测', () {
    // ---- Web 检测（基础值） ----
    test('isWeb 返回值类型为 bool', () {
      // kIsWeb 在测试环境通常为 false
      expect(PlatformUtils.isWeb, isA<bool>());
    });

    // ---- 平台名称 ----
    test('platformName 返回非空字符串', () {
      expect(PlatformUtils.platformName, isNotEmpty);
      expect(PlatformUtils.platformName, isA<String>());
    });

    // ---- 组合逻辑 ----
    test('isMobile 返回 bool 值', () {
      expect(PlatformUtils.isMobile, isA<bool>());
    });

    test('isDesktop 返回 bool 值', () {
      expect(PlatformUtils.isDesktop, isA<bool>());
    });

    test('isMobile 和 isDesktop 不会同时为 true（Web 环境除外）', () {
      if (!PlatformUtils.isWeb) {
        // 在非 Web 环境下，移动端和桌面端互斥
        // 注意：某些平台可能两者都为 false（如测试环境）
        expect(
          PlatformUtils.isMobile && PlatformUtils.isDesktop,
          isFalse,
          reason: '不能同时是移动端和桌面端',
        );
      }
    });

    // ---- 鸿蒙检测 ----
    test('isOhos 返回 bool 值，不抛异常', () {
      // 在非鸿蒙环境下应为 false
      // 关键：调用不抛异常
      expect(() => PlatformUtils.isOhos, returnsNormally);
      expect(PlatformUtils.isOhos, isA<bool>());
    });
  });

  group('PlatformUtils — 设备信息', () {
    testWidgets('isLargeScreen: 窄屏幕（300px）返回 false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(PlatformUtils.isLargeScreen(context), isFalse);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // 设置窄屏幕宽度
      tester.view.physicalSize = const Size(300 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
    });

    testWidgets('isLargeScreen: 宽屏幕（800px）返回 true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(PlatformUtils.isLargeScreen(context), isTrue);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // 设置宽屏幕
      tester.view.physicalSize = const Size(800 * 3, 600 * 3);
      tester.view.devicePixelRatio = 3.0;
      await tester.pump();
    });

    testWidgets('devicePixelRatio 返回正值', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final dpr = PlatformUtils.devicePixelRatio(context);
              expect(dpr, greaterThan(0));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}