# 易比价 (EasyPrice) — 端到端测试报告

> **生成时间**：2026-06-01  
> **项目路径**：`/home/liufp/easy_price/`  
> **测试环境**：WSL (Windows Subsystem for Linux)，Flutter/Dart SDK 不可用  
> **报告说明**：本报告总结测试套件的覆盖范围、结构和使用方法。

---

## 一、测试套件总览

| 类别 | 文件数 | 测试用例数（约） | 可运行环境 |
|------|--------|:---:|-----------|
| 数据模型单元测试 | 2 | 35+ | ✅ `dart test` |
| 工具类单元测试 | 1 | 20+ | ✅ `dart test` |
| 平台检测单元测试 | 1 | 8 | ⚠️ 需 Flutter |
| 存储服务单元测试 | 1 | 16 | ⚠️ 需 Flutter |
| Widget 测试 | 4 | 25+ | ⚠️ 需 Flutter |
| 集成测试场景文档 | 1 | 10 场景 | 📖 文档 |
| **合计** | **10** | **100+** | |

---

## 二、测试覆盖详情

### 2.1 数据模型测试（纯 Dart ✅）

#### `test/models/product_test.dart`
- **PricePoint**：JSON 序列化/反序列化、hasDiscount 逻辑（降价/平价/涨价）、discountPercent 计算（含除零保护）
- **Product**：fromJson/toJson、空字段容错、prices 为 null 处理、minPrice/maxPrice/platformCount 业务逻辑

#### `test/models/search_result_test.dart`
- **SearchResult**：fromJson/toJson、hasMore 分页判断、isEmpty/isNotEmpty
- **TrendingItem**：fromJson/toJson、类型转换（int→double）、序列化互逆验证

### 2.2 工具类测试（纯 Dart ✅）

#### `test/utils/price_formatter_test.dart`
- **format()**：千分位逗号（1,299 / 1,000,000）、小于千位、小数处理、showDecimal 参数、负数、边界值
- **formatNumber()**：去掉 ¥ 前缀
- **formatRange()**：价格区间、相同价格简化
- **formatDiscount()**：折扣格式化、千分位价格折扣
- 共 20+ 测试用例

### 2.3 平台检测测试（需 Flutter ⚠️）

#### `test/utils/platform_utils_test.dart`
- 运行时平台检测（isWeb/isMobile/isDesktop/isOhos）
- 设备信息（isLargeScreen 自适应、devicePixelRatio）
- 互斥逻辑验证

### 2.4 存储服务测试（需 Flutter ⚠️）

#### `test/services/storage_service_test.dart`
- **收藏功能**：增删查、去重、批量操作
- **搜索历史**：添加/去重/排序/50条上限/清空
- **数据隔离**：收藏与历史互不干扰
- 使用 `SharedPreferences.setMockInitialValues` 模拟

### 2.5 Widget 组件测试（需 Flutter ⚠️）

#### `test/widgets/price_tag_test.dart`
- PriceTag：降价/不降价显示、showSymbol 参数、small/medium/large 尺寸
- DiscountBadge：有折扣/无折扣/涨价场景

#### `test/widgets/empty_state_test.dart`
- 基础渲染（标题/默认图标/自定义图标）
- 副标题显示/隐藏
- 操作按钮显示/隐藏条件、点击回调

#### `test/widgets/error_retry_test.dart`
- 错误消息显示、重试按钮渲染、错误图标
- 点击回调触发、多次点击

#### `test/widgets/skeleton_loader_test.dart`
- 默认参数、自定义 itemCount/childAspectRatio
- 边界情况（0/1/20 个骨架卡片）
- 自适应列数（窄屏 2 列 / 中屏 3 列 / 宽屏 4 列）

### 2.6 集成测试场景（文档 📖）

#### `test/integration/e2e_scenarios.md`
10 个核心用户路径场景：
1. 搜索商品 → 结果 → 详情 → 返回
2. 首页 Tab 切换（首页/发现/我的）
3. 搜索建议与实时联想
4. 搜索历史持久化
5. 空状态/错误状态展示
6. 商品详情与比价列表
7. 发现页热门商品浏览
8. 我的页面收藏与历史管理
9. 结果页排序切换
10. 网络异常与重试机制

---

## 三、发现的问题和建议

### 3.1 代码问题

| 问题 | 严重程度 | 位置 | 建议 |
|------|:---:|------|------|
| `shimmer_widgets.dart` 被 `widgets.dart` 导出但文件不存在 | 🔴 高 | `lib/widgets/widgets.dart:4` | 创建该文件或移除导出 |
| `utils/platform_utils.dart` 同时使用 `package:flutter/foundation.dart` 和 `dart:io` 的 `Platform` | 🟡 中 | `lib/utils/platform_utils.dart:1-2` | 无冲突，但需注意 Web 编译需条件导入 |
| `search_provider.dart` 和 `storage_service.dart` 重复定义 `search_history` key | 🟡 中 | 两个文件各自定义 | 统一使用 StorageService 的常量 |
| `detail_page.dart` 中有大量硬编码 Mock 数据 | 🟢 低 | `lib/pages/detail/detail_page.dart:134-139` | 接入真实 API 后移除 |
| `trending_service.dart` 硬编码 `api.example.com` 作为 baseUrl | 🟢 低 | `lib/services/trending_service.dart:8` | 建议通过环境变量或配置注入 |
| `analysis_options.yaml` 引用 `package:flutter_lints/flutter.yaml` | 🟢 低 | `analysis_options.yaml:1` | 确保 pubspec.yaml 中 `flutter_lints` 版本匹配 |

### 3.2 架构建议

1. **依赖注入**：建议引入依赖注入容器（如 `get_it`），方便测试时替换 ApiService/StorageService 为 mock 实现
2. **错误处理统一化**：`api_service.dart` 和 `trending_service.dart` 各自定义了异常类（`ApiException` vs `NetworkException`），建议统一
3. **测试辅助工具**：建议创建 `test/test_helpers/` 目录存放 mock 数据、工具函数
4. **GitHub Actions CI**：添加 GitHub Actions 工作流，每次 PR 自动运行测试

---

## 四、运行测试的命令

### 纯 Dart 测试（无需 Flutter SDK）

```bash
cd /home/liufp/easy_price

# 确保 pubspec.yaml 中有 test 依赖
# dev_dependencies:
#   test: ^1.24.0

# 运行所有纯 Dart 测试
dart test test/models/ test/utils/price_formatter_test.dart

# 运行单个文件
dart test test/models/product_test.dart
dart test test/models/search_result_test.dart
dart test test/utils/price_formatter_test.dart

# 生成覆盖率报告（需要 lcov）
dart test --coverage=coverage test/models/ test/utils/price_formatter_test.dart
dart pub global activate coverage
dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib -i coverage -o coverage/lcov.info -l
```

### Flutter Widget / 集成测试（需要 Flutter SDK）

```bash
cd /home/liufp/easy_price

# 静态分析
flutter analyze

# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widgets/price_tag_test.dart
flutter test test/services/storage_service_test.dart
flutter test test/utils/platform_utils_test.dart

# 运行集成测试
flutter test integration_test/

# 生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 五、测试文件清单

```
test/
├── models/
│   ├── product_test.dart                  # ✅ 纯 Dart — Product/PricePoint 模型测试
│   └── search_result_test.dart            # ✅ 纯 Dart — SearchResult/TrendingItem 模型测试
├── utils/
│   ├── price_formatter_test.dart          # ✅ 纯 Dart — 价格格式化工具测试
│   └── platform_utils_test.dart           # ⚠️ 需 Flutter — 平台检测工具测试
├── services/
│   └── storage_service_test.dart          # ⚠️ 需 Flutter — 本地存储服务测试
├── widgets/
│   ├── price_tag_test.dart                # ⚠️ 需 Flutter — 价格标签组件测试
│   ├── empty_state_test.dart              # ⚠️ 需 Flutter — 空状态组件测试
│   ├── error_retry_test.dart              # ⚠️ 需 Flutter — 错误重试组件测试
│   └── skeleton_loader_test.dart          # ⚠️ 需 Flutter — 骨架屏组件测试
└── integration/
    └── e2e_scenarios.md                   # 📖 端到端场景文档

项目根目录/
└── TEST_REPORT.md                         # 📖 本报告
```

---

## 六、后续行动项

- [ ] 在 Flutter 环境中运行全部测试，确认通过率
- [ ] 修复 `shimmer_widgets.dart` 缺失问题
- [ ] 为 ApiService 编写 mock 测试
- [ ] 为 SearchProvider（Provider 状态管理）编写单元测试
- [ ] 创建 `integration_test/` 目录下的 Flutter 集成测试文件
- [ ] 配置 CI/CD 流水线自动运行测试