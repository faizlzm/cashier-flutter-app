import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';
import 'sidebar.dart';
import 'header.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isCompactHeight = context.isCompactHeight;
    
    // Use drawer for mobile OR landscape with compact height
    final useDrawer = isMobile || isCompactHeight;
    
    // Reduce header height in landscape
    final headerHeight = isCompactHeight ? 48.0 : 64.0;
    final contentPadding = isCompactHeight ? 8.0 : (isMobile ? 12.0 : 24.0);
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: useDrawer
          ? Drawer(
              child: Sidebar(
                isDrawer: true,
                onItemTap: _closeDrawer,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar - only show on desktop/tablet in portrait
          if (!useDrawer) const Sidebar(),
          
          // Main content
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Header(
                    onMenuPressed: useDrawer ? _openDrawer : null,
                    compact: isCompactHeight,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.all(contentPadding),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
