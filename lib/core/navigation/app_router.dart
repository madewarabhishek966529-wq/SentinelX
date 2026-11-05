import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/view/about_screen.dart';
import '../../features/events/view/security_events_screen.dart';
import '../../features/fim/view/file_integrity_screen.dart';
import '../../features/hardware/view/hardware_screen.dart';
import '../../features/network/view/network_activity_screen.dart';
import '../../features/network/view/network_devices_screen.dart';
import '../../features/overview/view/overview_screen.dart';
import '../../features/processes/view/processes_screen.dart';
import '../../features/protection/view/protection_screen.dart';
import '../../features/recommendations/view/recommendations_screen.dart';
import '../../features/reports/view/reports_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../../features/shell/view/shell_screen.dart';
import '../../features/startup/view/startup_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(child: OverviewScreen()),
        ),
        GoRoute(
          path: '/protection',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProtectionScreen()),
        ),
        GoRoute(
          path: '/hardware',
          pageBuilder: (context, state) => const NoTransitionPage(child: HardwareScreen()),
        ),
        GoRoute(
          path: '/processes',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProcessesScreen()),
        ),
        GoRoute(
          path: '/startup',
          pageBuilder: (context, state) => const NoTransitionPage(child: StartupScreen()),
        ),
        GoRoute(
          path: '/network-activity',
          pageBuilder: (context, state) => const NoTransitionPage(child: NetworkActivityScreen()),
        ),
        GoRoute(
          path: '/network-devices',
          pageBuilder: (context, state) => const NoTransitionPage(child: NetworkDevicesScreen()),
        ),
        GoRoute(
          path: '/file-integrity',
          pageBuilder: (context, state) => const NoTransitionPage(child: FileIntegrityScreen()),
        ),
        GoRoute(
          path: '/security-events',
          pageBuilder: (context, state) => const NoTransitionPage(child: SecurityEventsScreen()),
        ),
        GoRoute(
          path: '/recommendations',
          pageBuilder: (context, state) => const NoTransitionPage(child: RecommendationsScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => const NoTransitionPage(child: AboutScreen()),
        ),
      ],
    ),
  ],
);
