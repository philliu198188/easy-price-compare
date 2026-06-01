# 易比价 (EasyPrice)

跨平台比价 App — Flutter 前端 + Go 后端

## 快速开始

```bash
flutter pub get
flutter run
```

## 构建 APK

```bash
flutter build apk --release
# APK 输出: build/app/outputs/flutter-apk/app-release.apk
```

## 技术栈

- 前端: Flutter 3.x + Provider + GoRouter
- 后端: Go + Gin + GORM + PostgreSQL + Redis
- 测试: Dart test + Flutter test

## 项目结构

```
lib/
├── app.dart          # 路由 + 导航
├── main.dart         # 入口
├── models/           # 数据模型
├── pages/            # 页面 (home/discover/profile/detail/results)
├── services/         # API 服务层
├── theme/            # 主题 (colors/typography/spacing)
├── utils/            # 工具类
└── widgets/          # 通用组件
test/                 # 测试套件
android/              # Android 平台配置
ios/                  # iOS 平台配置
```

## 产品功能

- 🔍 商品搜索（精确 + 模糊匹配）
- 📊 多平台比价（淘宝/京东/拼多多等）
- 💰 价格走势与历史
- 📱 全平台（Android / iOS / 鸿蒙）