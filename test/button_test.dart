import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hl_ui/hl_ui.dart';

void main() {
  testWidgets('calls the supplied callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HlButton(label: 'Save', onPressed: () => tapped = true),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    expect(tapped, isTrue);
  });

  testWidgets('does not invoke callbacks while loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HlButton(
            label: 'Save',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    expect(tapped, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
