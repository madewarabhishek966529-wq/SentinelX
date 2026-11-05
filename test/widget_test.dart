import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelx/core/models/component_status.dart';
import 'package:sentinelx/main.dart';
import 'package:sentinelx/shared/widgets/status_badge.dart';

void main() {
  group('SentinelX Stage 1 Foundation Tests', () {
    testWidgets('App shell renders with TopBar, Sidebar, and honest Overview screen', (WidgetTester tester) async {
      // Set desktop window surface size for testing
      tester.view.physicalSize = const Size(1280, 820);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: SentinelXApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app branding and top bar
      expect(find.text('SentinelX'), findsWidgets);
      expect(find.text('Security Overview'), findsWidgets);

      // Verify sidebar navigation links
      expect(find.text('Protection Status'), findsOneWidget);
      expect(find.text('Device & Hardware'), findsOneWidget);
      expect(find.text('Processes'), findsWidgets);
      expect(find.text('Startup Apps'), findsOneWidget);
      expect(find.text('Network Activity'), findsWidgets);
      expect(find.text('File Integrity'), findsWidgets);

      // Verify no fake 0-100 score or fake threat counter
      expect(find.text('Security Score'), findsNothing);
      expect(find.text('100% Protected'), findsNothing);
      expect(find.text('Threats Blocked: 0'), findsNothing);
    });

    testWidgets('StatusBadge renders all 7 explicit semantic states correctly', (WidgetTester tester) async {
      for (final status in ComponentStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(status: status),
            ),
          ),
        );

        expect(find.text(status.label), findsOneWidget);
        expect(find.byIcon(status.icon), findsOneWidget);
      }
    });

    test('ComponentStatus string mapping handles unknown and explicit values honestly', () {
      expect(ComponentStatus.fromString('enabled'), ComponentStatus.enabled);
      expect(ComponentStatus.fromString('disabled'), ComponentStatus.disabled);
      expect(ComponentStatus.fromString('unsupported'), ComponentStatus.unsupported);
      expect(ComponentStatus.fromString('access_denied'), ComponentStatus.accessDenied);
      expect(ComponentStatus.fromString('error'), ComponentStatus.error);
      expect(ComponentStatus.fromString('stale'), ComponentStatus.stale);
      expect(ComponentStatus.fromString('unknown'), ComponentStatus.unknown);
      // Missing or unrecognized value must be mapped to Unknown, NEVER enabled
      expect(ComponentStatus.fromString(null), ComponentStatus.unknown);
      expect(ComponentStatus.fromString('some_weird_value'), ComponentStatus.unknown);
    });
  });
}
