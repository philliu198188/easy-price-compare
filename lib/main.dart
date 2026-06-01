import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home/search_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EasyPriceApp());
}

/// App 入口 — Provider 层 + GoRouter
class EasyPriceApp extends StatelessWidget {
  const EasyPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: const EasyPriceMaterialApp(),
    );
  }
}