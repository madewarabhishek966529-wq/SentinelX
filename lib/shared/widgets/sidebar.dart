import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/sentinel_colors.dart';
import '../../core/theme/sentinel_typography.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String route;

  const SidebarItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class Sidebar extends StatefulWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isCollapsed = false;

  static const List<SidebarItem> items = [
    SidebarItem(title: 'Security Overview', icon: Icons.dashboard_outlined, route: '/'),
    SidebarItem(title: 'Protection Status', icon: Icons.security_outlined, route: '/protection'),
    SidebarItem(title: 'Device & Hardware', icon: Icons.memory_outlined, route: '/hardware'),
    SidebarItem(title: 'Processes', icon: Icons.list_alt_outlined, route: '/processes'),
    SidebarItem(title: 'Startup Apps', icon: Icons.rocket_launch_outlined, route: '/startup'),
    SidebarItem(title: 'Network Activity', icon: Icons.sync_alt_outlined, route: '/network-activity'),
    SidebarItem(title: 'Network Devices', icon: Icons.lan_outlined, route: '/network-devices'),
    SidebarItem(title: 'File Integrity', icon: Icons.folder_shared_outlined, route: '/file-integrity'),
    SidebarItem(title: 'Security Events', icon: Icons.notifications_active_outlined, route: '/security-events'),
    SidebarItem(title: 'Recommendations', icon: Icons.lightbulb_outline, route: '/recommendations'),
    SidebarItem(title: 'Reports', icon: Icons.description_outlined, route: '/reports'),
    SidebarItem(title: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = _isCollapsed ? 68.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      decoration: const BoxDecoration(
        color: SentinelColors.surface,
        border: Border(right: BorderSide(color: SentinelColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Header Logo & App Title
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SentinelColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SentinelColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.shield, size: 20, color: SentinelColors.primary),
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SentinelX',
                      style: SentinelTypography.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          // Navigation items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = widget.currentRoute == item.route ||
                    (item.route != '/' && widget.currentRoute.startsWith(item.route));

                final navTile = InkWell(
                  onTap: () => context.go(item.route),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? SentinelColors.surfaceHighlight : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? SentinelColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: isSelected ? SentinelColors.primary : SentinelColors.textSecondary,
                        ),
                        if (!_isCollapsed) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? SentinelColors.textPrimary : SentinelColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );

                if (_isCollapsed) {
                  return Tooltip(
                    message: item.title,
                    preferBelow: false,
                    child: navTile,
                  );
                }
                return navTile;
              },
            ),
          ),
          const Divider(),
          // Footer: Collapse toggle
          InkWell(
            onTap: () => setState(() => _isCollapsed = !_isCollapsed),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 20,
                    color: SentinelColors.textMuted,
                  ),
                  if (!_isCollapsed) ...[
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Collapse Sidebar',
                        style: SentinelTypography.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
