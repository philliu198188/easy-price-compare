import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/home/home_page.dart';
import 'pages/discover/discover_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/results/results_page.dart';
import 'pages/detail/detail_page.dart';

/// 全局路由 key — 用于在 shell 之外导航时恢复状态
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter 路由配置
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── 底部 Tab 导航 (shell) ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: 首页 🏠
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Tab 1: 发现 🔥
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverPage(),
            ),
          ],
        ),
        // Tab 2: 我的 👤
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // ── 独立页面（无底部导航）──
    GoRoute(
      path: '/results',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return ResultsPage(query: query);
      },
    ),
    GoRoute(
      path: '/detail/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DetailPage(productId: id);
      },
    ),
  ],
);

/// 带底部导航栏的外壳 Widget — 集成 Android 返回键处理
class ScaffoldWithNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  DateTime? _lastBackPressed;

  /// 处理 Android 返回键：
  /// - 非首页 Tab → 切换回首页
  /// - 首页 Tab → 第一次按提示"再按一次退出"，2秒内再次按则退出 App
  Future<bool> _onWillPop() async {
    final shell = widget.navigationShell;
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('再按一次退出'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return false;
    }
    return true; // 允许退出
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF3B82F6), // blue-500
          unselectedItemColor: const Color(0xFF94A3B8), // slate-400
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search_rounded),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              activeIcon: Icon(Icons.explore_rounded),
              label: '发现',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

/// MaterialApp.router — 使用 GoRouter
class EasyPriceMaterialApp extends StatelessWidget {
  const EasyPriceMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '易比价',
      debugShowCheckedModeBanner: false,
      // SafeArea 适配异形屏/刘海屏/挖孔屏
      builder: (context, child) {
        return SafeArea(
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          scrolledUnderElevation: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      routerConfig: router,
    );
  }
}