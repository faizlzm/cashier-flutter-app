import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/theme_provider.dart';

class Sidebar extends ConsumerStatefulWidget {
  final bool isDrawer;
  final VoidCallback? onItemTap;
  
  const Sidebar({
    super.key, 
    this.isDrawer = false,
    this.onItemTap,
  });

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentPath = GoRouterState.of(context).uri.path;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Drawer mode always expanded
    final isCollapsed = widget.isDrawer ? false : _collapsed;
    final sidebarWidth = widget.isDrawer ? 280.0 : (isCollapsed ? 80.0 : 240.0);

    final menuItems = [
      {'icon': LucideIcons.home, 'label': 'Home', 'path': '/dashboard'},
      {'icon': LucideIcons.shoppingBag, 'label': 'POS', 'path': '/pos'},
      {'icon': LucideIcons.clipboardList, 'label': 'Riwayat', 'path': '/transactions'},
      {'icon': LucideIcons.settings, 'label': 'Setting', 'path': '/settings'},
    ];

    void handleNavigation(String path) {
      context.go(path);
      widget.onItemTap?.call();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: widget.isDrawer 
            ? null 
            : Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showText = constraints.maxWidth > 150;
          return Column(
            children: [
              // Header
              Container(
                height: 64,
                padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment:
                      isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isCollapsed && showText)
                      Expanded(
                        child: Text(
                          'KASIR PRO',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    if (!widget.isDrawer)
                      IconButton(
                        icon: const Icon(LucideIcons.menu, size: 20),
                        onPressed: () => setState(() => _collapsed = !_collapsed),
                      ),
                  ],
                ),
              ),

              // Menu Navigation
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCollapsed ? 8 : 8,
                    vertical: 8,
                  ),
                  children: menuItems.map((item) {
                    final isActive = currentPath.startsWith(item['path'] as String);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: isActive ? cs.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => handleNavigation(item['path'] as String),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCollapsed ? 0 : 12,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 20,
                                  color: isActive
                                      ? cs.onPrimary
                                      : cs.onSurface.withValues(alpha: 0.6),
                                ),
                                if (!isCollapsed && showText) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['label'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isActive
                                            ? cs.onPrimary
                                            : cs.onSurface.withValues(alpha: 0.8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Footer (Theme Toggle + Logout)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 8 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme Toggle
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCollapsed ? 0 : 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                            children: [
                              Icon(
                                isDark ? LucideIcons.sun : LucideIcons.moon,
                                size: 18,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                              if (!isCollapsed && showText) ...[
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    isDark ? 'Light Mode' : 'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: cs.onSurface.withValues(alpha: 0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Logout
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          context.go('/login');
                          widget.onItemTap?.call();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCollapsed ? 0 : 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                            children: [
                              Icon(LucideIcons.logOut, size: 18, color: cs.error),
                              if (!isCollapsed && showText) ...[
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: cs.error,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
