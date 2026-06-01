# 鸿蒙 (HarmonyOS) 平台适配文档

> 项目：易比价 (EasyPrice) — Flutter 跨平台比价 App  
> 更新日期：2025-06  
> Flutter SDK：3.1+

---

## 目录

1. [flutter_ohos 生态现状](#1-flutter_ohos-生态现状)
2. [方案对比与推荐](#2-方案对比与推荐)
3. [适配路线图](#3-适配路线图)
4. [平台检测工具](#4-平台检测工具)
5. [布局自适应策略](#5-布局自适应策略)
6. [依赖库兼容性](#6-依赖库兼容性)
7. [预估工作量](#7-预估工作量)

---

## 1. flutter_ohos 生态现状

### 1.1 官方支持情况

| 项目 | 状态 |
|------|------|
| Flutter 官方 SDK | ❌ **不支持** — 标准 Flutter SDK 不含 OHOS target |
| OpenHarmony SIG Flutter | ✅ 华为 OpenHarmony SIG 维护 Flutter 分支 (gitee.com/openharmony-sig) |
| pub.dev 官方包 | ❌ `flutter_ohos` 在 pub.dev 上**不存在** |
| OHOS 适配的第三方包 | ⚠️ 少量，如 `permission_handler_ohos`、`flutter_js_ohos` |
| 开发环境 | ✅ DevEco Studio + OHOS Flutter 分支 + HarmonyOS SDK 5.0.0(12) |

### 1.2 关键发现

- **flutter_ohos 不是一个 pub.dev 包**，而是 Flutter 引擎的 OHOS 分支。
- 接入方式为：切换 Flutter SDK 到 OpenHarmony SIG 维护的版本。
- 创建项目命令：`flutter create --platforms ohos`
- 构建命令：`flutter build hap --debug`
- 插件生态极度不成熟，大部分 pub.dev 上的 Flutter 插件**不支持** OHOS。

### 1.3 当前项目依赖在 OHOS 上的兼容性

| 依赖 | OHOS 可用性 | 说明 |
|------|------------|------|
| `provider` | ❓ 未知 | 纯 Dart 逻辑，理论上可运行；需验证 |
| `go_router` | ❓ 未知 | 依赖 Flutter Navigation，需 OHOS 分支验证 |
| `http` | ⚠️ | 网络库，OHOS 需要原生 HTTP 适配 |
| `shared_preferences` | ❌ 需适配 | 需要 OHOS 平台实现（存储 API 不同） |
| `cached_network_image` | ❌ 需适配 | 依赖文件系统，需 OHOS 实现 |
| `shimmer` | ✅ 可能可用 | 纯 UI 效果，无原生依赖 |
| `cupertino_icons` | ✅ 可用 | 纯字体/图标 |

---

## 2. 方案对比与推荐

### 方案 A：OHOS Flutter 分支（推荐 ⭐）

**适用场景**：需要复用现有 Flutter 代码，团队有 Flutter 经验。

**步骤**：
1. 安装 OpenHarmony SIG Flutter SDK（基于 Flutter 3.13.9+）
2. 创建 OHOS 平台目录：`flutter create --platforms ohos`
3. 逐个适配原生依赖（shared_preferences, http 等）— 参考 gitee.com/openharmony-sig/flutter_packages
4. 在 DevEco Studio 中配置签名、打包为 HAP

**优点**：
- 复用 95% 的 Dart 业务代码
- 一次编写，多平台运行
- 热重载开发体验

**缺点**：
- Flutter OHOS 分支稳定性待验证
- 插件生态薄弱，原生依赖适配工作量大
- 社区支持有限

**当前项目可行性**：🟡 **中等**  
- 纯 Dart 页面/组件可直接运行  
- `shared_preferences`、`cached_network_image` 需找 OHOS 替代品  
- `http` 需验证 OHOS 网络权限和 API

---

### 方案 B：ArkUI + ArkTS 重写关键页面

**适用场景**：性能极致要求、深度集成鸿蒙原生能力、Flutter 生态无法满足。

**步骤**：
1. 使用 DevEco Studio 创建 ArkUI 项目
2. 将首页搜索、结果列表、详情比价等核心页面用 ArkTS 重新实现
3. 通过 Platform Channel 调用原生鸿蒙 API（如支付、推送、传感器）

**优点**：
- 原生性能，与鸿蒙系统深度集成
- 可使用鸿蒙分布式能力（跨设备协同）
- 长期维护成本低

**缺点**：
- 需完全重写 UI 层，开发成本高
- 团队需学习 ArkUI + ArkTS
- iOS/Android 代码无法复用

**当前项目可行性**：🔴 **低（当前阶段不推荐）**  
- 属于"重建"而非"适配"，成本巨大

---

### 方案 C：混合方案（推荐 ⭐⭐）

Flutter 负责 UI 层，通过 Platform Channel 桥接鸿蒙原生能力。

**架构**：
```
┌─────────────────────────┐
│   Flutter UI (Dart)     │  ← 复用现有代码
│   首页/搜索/详情/发现/我的  │
├─────────────────────────┤
│   Platform Channel       │  ← 桥接层
├─────────────────────────┤
│   OHOS Native (ArkTS)   │  ← 存储/网络/图片缓存
│   shared_preferences    │
│   HTTP client           │
│   Image cache           │
└─────────────────────────┘
```

**优点**：
- UI 层完全复用
- 原生能力按需接入
- 工作量可控

---

### 推荐结论

| 阶段 | 方案 | 说明 |
|------|------|------|
| **第一阶段（当前）** | **方案 A** | 使用 OHOS Flutter 分支验证基础运行 |
| **第二阶段** | **方案 C** | 逐步用 Platform Channel 替换原生依赖 |
| **第三阶段（可选）** | **方案 B** | 仅当性能/功能需要时，重写特定页面 |

---

## 3. 适配路线图

### 第一阶段：环境搭建与验证（1-2 周）

- [ ] 安装 DevEco Studio 和 HarmonyOS SDK
- [ ] 拉取 OpenHarmony SIG Flutter 分支
- [ ] 创建 OHOS 平台目录：`flutter create --platforms ohos`
- [ ] 在模拟器/真机上运行空白 Flutter App
- [ ] 集成 Dart 代码，验证纯 UI 页面渲染

### 第二阶段：依赖适配（2-4 周）

- [ ] `shared_preferences` → 替换为 `shared_preferences_ohos` 或 Platform Channel 实现
- [ ] `http` → 验证 OHOS 网络请求，必要时替换为 `http_ohos` 或原生 HTTP
- [ ] `cached_network_image` → 使用 OHOS 原生图片缓存替代
- [ ] `go_router` → 验证导航行为在 OHOS 上的兼容性

### 第三阶段：打磨与发布（1-2 周）

- [ ] 适配鸿蒙屏幕尺寸（折叠屏、平板等）
- [ ] 签名打包：`flutter build hap --release`
- [ ] 提交到 AppGallery Connect 审核

---

## 4. 平台检测工具

已在项目中创建 `lib/utils/platform_utils.dart`，提供统一的平台检测 API。

### 使用方式

```dart
import 'package:easy_price/utils/platform_utils.dart';

// 判断是否鸿蒙
if (PlatformUtils.isOhos) {
  // 鸿蒙特定逻辑
}

// 判断是否移动端（含鸿蒙）
if (PlatformUtils.isMobile) {
  // 移动端通用逻辑
}

// 判断大屏设备
if (PlatformUtils.isLargeScreen(context)) {
  // 平板/折叠屏 layout
}
```

### 检测原理

1. **优先**：检查 `defaultTargetPlatform`（OHOS Flutter 分支中包含 `TargetPlatform.ohos`）
2. **回退**：`dart:io` `Platform.operatingSystem` 字符串匹配 `"ohos"`
3. **Web 保护**：Web 平台提前返回，避免访问 `dart:io`

---

## 5. 布局自适应策略

### 5.1 已验证的适配措施

| 策略 | 实现 | 涉及文件 |
|------|------|----------|
| 自适应网格列数 | `LayoutBuilder` + `_adaptiveColumnCount()` | `results_page.dart`, `discover_page.dart`, `skeleton_loader.dart` |
| 自适应宽高比 | `_adaptiveAspectRatio()` 根据列数调整 | 同上 |
| 平台检测 | `PlatformUtils` 工具类 | `platform_utils.dart` |
| 间距规范 | `AppSpacing` 使用 8px 基准相对单位 | `theme/spacing.dart` |
| 字体规范 | `AppFontSize` / `AppTextStyles` 统一字号 | `theme/typography.dart` |

### 5.2 鸿蒙特有适配建议

| 适配点 | 说明 | 实现方式 |
|--------|------|----------|
| **折叠屏** | 折叠/展开状态切换布局 | `MediaQuery.of(context).size.width` 监听 |
| **平行视界** | 大屏时左侧列表+右侧详情双栏 | 基于 `LayoutBuilder` 宽度 >= 840dp 切换 |
| **系统返回手势** | 鸿蒙侧滑返回 | Flutter `WillPopScope` / GoRouter |
| **状态栏/导航栏高度** | 鸿蒙沉浸式适配 | `MediaQuery.of(context).padding.top` |
| **字体大小跟随系统** | 鸿蒙无障碍 | 使用 `textScaleFactor` |
| **深色模式** | 鸿蒙跟随系统主题 | `MediaQuery.of(context).platformBrightness` |

### 5.3 网格自适应列数规则

```
屏幕宽度 < 600dp  →  2 列（手机竖屏）
屏幕宽度 600-899  →  3 列（平板竖屏/手机横屏）
屏幕宽度 >= 900   →  4 列（平板横屏/桌面）
```

---

## 6. 依赖库兼容性

### 6.1 建议替换清单

| 当前依赖 | OHOS 替代方案 | 替代来源 |
|---------|-------------|----------|
| `shared_preferences` | `shared_preferences_ohos` | gitee.com/openharmony-sig |
| `http` | 原生 `@ohos.net.http` via Platform Channel | 鸿蒙 API |
| `cached_network_image` | 自实现（Flutter 内存缓存 + 原生磁盘缓存） | 自研 |
| `go_router` | 保持（纯 Dart，可能直接可用） | — |
| `provider` | 保持（纯 Dart） | — |
| `shimmer` | 保持（纯 UI） | — |

### 6.2 pubspec.yaml 建议补充

```yaml
# 仅在 OHOS Flutter 分支编译时添加
dependency_overrides:
  shared_preferences:
    git:
      url: https://gitee.com/openharmony-sig/flutter_packages.git
      path: packages/shared_preferences/shared_preferences
  # 其他 OHOS 适配包同理
```

---

## 7. 预估工作量

### 总体评估

| 阶段 | 内容 | 工作量 | 风险 |
|------|------|--------|------|
| 第一阶段 | 环境搭建 + 空白 App 验证 | 3-5 人天 | 低 |
| 第二阶段 | 原生依赖适配 | 10-15 人天 | 中 |
| 第三阶段 | 屏幕适配 + 测试 + 发布 | 5-8 人天 | 中 |
| **合计** | | **18-28 人天** | |

### 关键风险

1. **Flutter OHOS 分支稳定性**：非官方维护，可能滞后于 Flutter 主线
2. **插件生态**：依赖的 OHOS 替代包可能质量参差不齐
3. **华为审核**：AppGallery 上架审核标准可能持续变化
4. **API 兼容性**：HarmonyOS NEXT 与 OpenHarmony API 不完全一致

### 缓解措施

- 优先在 HarmonyOS NEXT 真机/模拟器上验证
- 对关键依赖（网络、存储）提前做 Platform Channel 桩代码
- 与 OpenHarmony SIG 社区保持沟通

---

## 附录

### A. 参考资源

- [OpenHarmony SIG Flutter Packages](https://gitee.com/openharmony-sig/flutter_packages)
- [Flutter for OpenHarmony 开发环境搭建](https://dev.to/flfljh/setting-up-flutter-development-environment-for-harmonyos-hik)
- [HarmonyOS Flutter 插件适配指南](https://dev.to/flfljh/adapting-flutter-plugins-for-openharmony-ohos-1ek2)
- [HarmonyOS 开发者官网](https://developer.harmonyos.com/)

### B. 已完成的适配工作

- [x] 平台检测工具：`lib/utils/platform_utils.dart`
- [x] 自适应网格布局：`results_page.dart`, `discover_page.dart`, `skeleton_loader.dart`
- [x] 布局自适应策略文档化
- [x] 鸿蒙适配路线图