import 'package:flutter/material.dart';

/// 易比价全局颜色定义
class AppColors {
  AppColors._();

  // ========== 品牌色 ==========
  /// 主色 — 蓝色 #3B82F6
  static const Color primary = Color(0xFF3B82F6);

  /// 主色浅色
  static const Color primaryLight = Color(0xFF60A5FA);

  /// 主色深色
  static const Color primaryDark = Color(0xFF2563EB);

  /// 辅色 — 橙色 #F97316
  static const Color secondary = Color(0xFFF97316);

  /// 辅色浅色
  static const Color secondaryLight = Color(0xFFFB923C);

  // ========== 中性色 (Slate 蓝灰系) ==========
  /// 背景色 — 浅灰蓝
  static const Color background = Color(0xFFF1F5F9);

  /// 卡片/白色区域背景
  static const Color surface = Color(0xFFF8FAFC);

  /// 文字 — 主文字 #0F172A
  static const Color textPrimary = Color(0xFF0F172A);

  /// 文字 — 次要 #475569
  static const Color textSecondary = Color(0xFF475569);

  /// 文字 — 提示/占位 #94A3B8
  static const Color textHint = Color(0xFF94A3B8);

  /// 分割线
  static const Color divider = Color(0xFFE2E8F0);

  // ========== 功能色 ==========
  /// 成功 — 绿色
  static const Color success = Color(0xFF22C55E);

  /// 警告 — 黄色
  static const Color warning = Color(0xFFF59E0B);

  /// 错误 — 红色
  static const Color error = Color(0xFFEF4444);

  /// 价格 — 红色醒目
  static const Color price = Color(0xFFDC2626);

  /// 原价删除线
  static const Color originalPrice = Color(0xFF94A3B8);
}