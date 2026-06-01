/// 易比价全局间距与尺寸规范
/// 基准：8px
class AppSpacing {
  AppSpacing._();

  // ========== 间距 (8px 基准) ==========
  /// 4px — 极小间距
  static const double xs = 4.0;

  /// 8px — 小间距
  static const double s = 8.0;

  /// 12px — 中小间距
  static const double ms = 12.0;

  /// 16px — 中等间距
  static const double m = 16.0;

  /// 20px — 中大间距
  static const double ml = 20.0;

  /// 24px — 大间距
  static const double l = 24.0;

  /// 32px — 超大间距
  static const double xl = 32.0;

  /// 48px — 极大间距
  static const double xxl = 48.0;

  // ========== 圆角 ==========
  /// 4px — 小圆角
  static const double radiusXs = 4.0;

  /// 8px — 中小圆角
  static const double radiusS = 8.0;

  /// 12px — 中等圆角
  static const double radiusM = 12.0;

  /// 16px — 中大圆角
  static const double radiusL = 16.0;

  /// 24px — 大圆角
  static const double radiusXl = 24.0;

  /// 9999 — 胶囊/全圆角
  static const double radiusFull = 9999.0;

  // ========== 触摸目标 ==========
  /// 最小触摸目标 44×44pt
  static const double tapTarget = 44.0;

  // ========== 图标 ==========
  /// 小图标
  static const double iconS = 16.0;

  /// 中等图标
  static const double iconM = 24.0;

  /// 大图标
  static const double iconL = 32.0;

  // ========== 头像 ==========
  /// 小头像
  static const double avatarS = 32.0;

  /// 中等头像
  static const double avatarM = 48.0;

  /// 大头像
  static const double avatarL = 64.0;

  // ========== 卡片 ==========
  /// 卡片圆角
  static const double cardRadius = radiusM;

  /// 卡片高度
  static const double cardElevation = 2.0;
}