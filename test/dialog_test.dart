import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hl_ui/hl_ui.dart';

void main() {
  testWidgets('closes loading after a page is pushed and popped', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final feedback = HlFeedback(navigatorKey: navigatorKey);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: const Scaffold(body: Text('Create order')),
      ),
    );

    feedback.showLoading(loadingWidget: const Text('Creating order'));
    await tester.pump();
    expect(find.text('Creating order'), findsOneWidget);

    navigatorKey.currentState!.push<void>(
      MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Receive'))),
    );
    feedback.closeAllLoading();
    await tester.pumpAndSettle();

    expect(find.text('Receive'), findsOneWidget);
    await navigatorKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Create order'), findsOneWidget);
    expect(find.text('Creating order'), findsNothing);
  });
}
