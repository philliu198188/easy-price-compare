import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// 平台检测工具类
///
/// 用于运行时判断当前运行平台，支持鸿蒙 (HarmonyOS/OpenHarmony) 检测。
///
/// 使用方式：
/// ```dart
/// import 'package:easy_price/utils/platform_utils.dart';
///
/// if (PlatformUtils.isOhos) {
///   // 鸿蒙特定逻辑（字号调整、组件替换等）
/// }
///
/// if (PlatformUtils.isMobile) {
///   // 移动端通用逻辑
/// }
/// ```
///
/// 检测原理：
/// 1. 优先通过 Flutter 的 [defaultTargetPlatform] 判断（标准平台）。
/// 2. 鸿蒙检测回退到 `dart:io` 的 [Platform.operatingSystem]：
///    OHOS Flutter 分支编译的 App 中返回 `"ohos"`。
/// 3. Web 平台通过 [kIsWeb] 提前识别，避免访问 dart:io。
class PlatformUtils {
  PlatformUtils._();

  // ───────────────────────────────────────────────
  // 平台枚举
  // ───────────────────────────────────────────────

  /// 是否鸿蒙 (HarmonyOS / OpenHarmony)
  static bool get isOhos {
    if (kIsWeb) return false;
    // 方案1: OHOS Flutter 分支中 defaultTargetPlatform 包含 ohos
    if (_defaultTargetPlatformName() == 'ohos') return true;
    // 方案2: dart:io Platform.operatingSystem 返回 "ohos"
    try {
      return Platform.operatingSystem == 'ohos';
    } catch (_) {
      return false;
    }
  }

  /// 是否 Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return defaultTargetPlatform == TargetPlatform.android;
    } catch (_) {
      return false;
    }
  }

  /// 是否 iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return defaultTargetPlatform == TargetPlatform.iOS;
    } catch (_) {
      return false;
    }
  }

  /// 是否移动端 (Android / iOS / 鸿蒙)
  static bool get isMobile => isAndroid || isIOS || isOhos;

  /// 是否桌面端
  static bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux;
    } catch (_) {
      return false;
    }
  }

  /// 是否 Web
  static bool get isWeb => kIsWeb;

  // ───────────────────────────────────────────────
  // 平台信息（日志/调试用）
  // ───────────────────────────────────────────────

  /// 当前平台名称
  static String get platformName {
    if (isWeb) return 'web';
    if (isOhos) return 'ohos';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    try {
      return defaultTargetPlatform.name;
    } catch (_) {
      return 'unknown';
    }
  }

  /// 当前设备像素比（用于鸿蒙等大屏设备的适配判断）
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// 是否为平板/折叠屏类大屏设备（逻辑宽度 >= 600dp）
  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  // ───────────────────────────────────────────────
  // 私有辅助
  // ───────────────────────────────────────────────

  /// 获取 defaultTargetPlatform 的字符串名称
  /// 避免直接引用 TargetPlatform.ohos（标准 SDK 中不存在该枚举值）
  static String _defaultTargetPlatformName() {
    try {
      return defaultTargetPlatform.toString();
    } catch (_) {
      return '';
    }
  }
}