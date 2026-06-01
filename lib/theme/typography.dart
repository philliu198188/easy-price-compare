import 'package:flutter/material.dart';

/// 字号定义
class AppFontSize {
  AppFontSize._();

  /// 10px — 极小 / 标签
  static const double xs = 10.0;

  /// 12px — 辅助文字 / 说明
  static const double s = 12.0;

  /// 14px — 正文
  static const double m = 14.0;

  /// 16px — 子标题
  static const double l = 16.0;

  /// 18px — 大标题
  static const double xl = 18.0;

  /// 20px — 特大标题
  static const double xxl = 20.0;

  /// 24px — 页面大标题
  static const double display = 24.0;

  /// 32px — 超大标题 / 价格
  static const double hero = 32.0;
}

/// 预设文字样式
class AppTextStyles {
  AppTextStyles._();

  static const _defaultFamily = 'PingFang SC';

  /// AppBar 标题: 18px / Semibold
  static const TextStyle appBarTitle = TextStyle(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    fontFamily: _defaultFamily,
  );

  /// 按钮文字: 16px / Medium
  static const TextStyle button = TextStyle(
    fontSize: AppFontSize.l,
    fontWeight: FontWeight.w500,
    fontFamily: _defaultFamily,
  );

  /// 大标题: 24px / Bold
  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppFontSize.display,
    fontWeight: FontWeight.w700,
    color: Color(0xFF0F172A),
    fontFamily: _defaultFamily,
    height: 1.3,
  );

  /// 标题: 18px / Semibold
  static const TextStyle headline = TextStyle(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w600,
    color: Color(0xFF0F172A),
    fontFamily: _defaultFamily,
    height: 1.4,
  );

  /// 子标题: 16px / Medium
  static const TextStyle subtitle = TextStyle(
    fontSize: AppFontSize.l,
    fontWeight: FontWeight.w500,
    color: Color(0xFF0F172A),
    fontFamily: _defaultFamily,
    height: 1.4,
  );

  /// 正文: 14px / Regular
  static const TextStyle body = TextStyle(
    fontSize: AppFontSize.m,
    fontWeight: FontWeight.w400,
    color: Color(0xFF0F172A),
    fontFamily: _defaultFamily,
    height: 1.5,
  );

  /// 次要文字: 12px / Regular
  static const TextStyle bodySecondary = TextStyle(
    fontSize: AppFontSize.s,
    fontWeight: FontWeight.w400,
    color: Color(0xFF475569),
    fontFamily: _defaultFamily,
    height: 1.5,
  );

  /// 说明 / 标签: 10px / Regular
  static const TextStyle caption = TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w400,
    color: Color(0xFF94A3B8),
    fontFamily: _defaultFamily,
    height: 1.4,
  );

  /// 价格大字: 24px / Bold / 红色
  static const TextStyle priceLarge = TextStyle(
    fontSize: AppFontSize.display,
    fontWeight: FontWeight.w700,
    color: Color(0xFFDC2626),
    fontFamily: _defaultFamily,
  );

  /// 价格中字: 18px / Bold / 红色
  static const TextStyle priceMedium = TextStyle(
    fontSize: AppFontSize.xl,
    fontWeight: FontWeight.w600,
    color: Color(0xFFDC2626),
    fontFamily: _defaultFamily,
  );

  /// 原价删除线: 12px / Regular
  static const TextStyle originalPrice = TextStyle(
    fontSize: AppFontSize.s,
    fontWeight: FontWeight.w400,
    color: Color(0xFF94A3B8),
    decoration: TextDecoration.lineThrough,
    fontFamily: _defaultFamily,
  );
}