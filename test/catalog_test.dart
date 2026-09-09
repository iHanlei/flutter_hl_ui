import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hl_ui/hl_ui.dart';

void main() {
  testWidgets('uses supplied theme tokens for a card and badge', (
    tester,
  ) async {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    await tester.pumpWidget(
      MaterialApp(
        home: HlTheme(
          data: HlThemeData(colorScheme: colorScheme),
          child: const Scaffold(
            body: HlCard(child: HlBadge(label: 'Active')),
          ),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
    expect(find.byType(HlCard), findsOneWidget);
  });

  testWidgets('returns selected values from choice chips', (tester) async {
    var selected = <String>{'TRON'};
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: HlChoiceGroup<String>(
              multiSelect: true,
              values: selected,
              options: const [
                HlChoiceOption(value: 'TRON', label: 'TRON'),
                HlChoiceOption(value: 'ETH', label: 'ETH'),
              ],
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ETH'));
    expect(selected, {'TRON', 'ETH'});
  });
}
