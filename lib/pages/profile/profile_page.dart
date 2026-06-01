import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../widgets/empty_state.dart';

/// 我的页 — 收藏、历史、设置
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> _favorites = [];
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final favs = await StorageService.getFavorites();
    final history = await StorageService.getSearchHistory();
    if (mounted) {
      setState(() {
        _favorites = favs;
        _searchHistory = history;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空搜索历史'),
        content: const Text('确定要清空所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearSearchHistory();
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ---- 收藏 ----
          _SectionHeader(title: '我的收藏', count: _favorites.length),
          if (_favorites.isEmpty)
            const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: '暂无收藏',
              subtitle: '去发现页逛逛，收藏喜欢的商品',
            )
          else
            ..._favorites.map((id) => ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 20),
                  ),
                  title: Text('商品 #$id', style: const TextStyle(fontSize: 14)),
                  subtitle: const Text('点击查看详情', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                  onTap: () => context.go('/detail/$id'),
                )),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // ---- 搜索历史 ----
          _SectionHeader(
            title: '搜索历史',
            count: _searchHistory.length,
            trailing: _searchHistory.isNotEmpty
                ? TextButton(
                    onPressed: _clearHistory,
                    child: const Text('清空', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  )
                : null,
          ),
          if (_searchHistory.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: '暂无搜索历史',
              subtitle: '试试搜索你感兴趣的商品',
            )
          else
            ..._searchHistory.map((keyword) => ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  title: Text(keyword, style: const TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.north_west_rounded, color: Color(0xFFCBD5E1), size: 18),
                  onTap: () => context.go('/results?q=$keyword'),
                )),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // ---- 设置 ----
          const _SectionHeader(title: '设置', count: 0),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
            ),
            title: const Text('关于易比价', style: TextStyle(fontSize: 14)),
            subtitle: const Text('v1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '易比价',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 28),
                ),
                children: const [
                  Text('跨平台商品比价助手，助你轻松找到全网最低价。'),
                ],
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// 区块标题组件
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.count,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}