import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../shared/widgets/sidebar.dart';
import '../../../shared/widgets/top_bar.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  String _getModuleTitle(String location) {
    if (location == '/') return 'Security Overview';
    if (location.startsWith('/protection')) return 'Protection Status';
    if (location.startsWith('/hardware')) return 'Device & Hardware Inventory';
    if (location.startsWith('/processes')) return 'Process Visibility';
    if (location.startsWith('/startup')) return 'Startup Applications';
    if (location.startsWith('/network-activity')) return 'Network Activity';
    if (location.startsWith('/network-devices')) return 'Network Devices (Authorized Discovery)';
    if (location.startsWith('/file-integrity')) return 'File Integrity Monitoring';
    if (location.startsWith('/security-events')) return 'Windows Security Events';
    if (location.startsWith('/recommendations')) return 'Actionable Recommendations';
    if (location.startsWith('/reports')) return 'Security Reports & Export';
    if (location.startsWith('/settings')) return 'Application Settings & Diagnostics';
    if (location.startsWith('/about')) return 'About SentinelX & Defensive Boundaries';
    return 'SentinelX';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final title = _getModuleTitle(location);

    return Scaffold(
      backgroundColor: SentinelColors.background,
      body: Row(
        children: [
          Sidebar(currentRoute: location),
          Expanded(
            child: Column(
              children: [
                TopBar(title: title),
                Expanded(
                  child: FocusTraversalGroup(
                    policy: ReadingOrderTraversalPolicy(),
                    child: child,
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

