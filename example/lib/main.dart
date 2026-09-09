import 'package:flutter/material.dart';
import 'package:hl_ui/hl_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    final feedback = HlFeedback(
      navigatorKey: navigatorKey,
      messengerKey: messengerKey,
    );
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF111827)),
      home: HlTheme(
        data: HlThemeData.fromMaterial(
          ThemeData(colorSchemeSeed: const Color(0xFF111827)),
        ),
        child: HlFeedbackScope(
          feedback: feedback,
          child: const _ComponentPreview(),
        ),
      ),
    );
  }
}

class _ComponentPreview extends StatefulWidget {
  const _ComponentPreview();

  @override
  State<_ComponentPreview> createState() => _ComponentPreviewState();
}

class _ComponentPreviewState extends State<_ComponentPreview> {
  String _currency = 'USD';
  Set<String> _networks = {'TRON'};

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('hl_ui')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HlCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HlBadge(label: 'Ready'),
              const SizedBox(height: 16),
              HlSelectField(
                label: 'Settlement currency',
                value: _currency,
                options: const [
                  HlSelectOption(value: 'USD', label: 'USD'),
                  HlSelectOption(value: 'MYR', label: 'MYR'),
                ],
                onChanged: (value) =>
                    setState(() => _currency = value ?? 'USD'),
              ),
              const SizedBox(height: 16),
              HlChoiceGroup(
                multiSelect: true,
                values: _networks,
                options: const [
                  HlChoiceOption(value: 'TRON', label: 'TRON'),
                  HlChoiceOption(value: 'ETH', label: 'Ethereum'),
                ],
                onChanged: (values) => setState(() => _networks = values),
              ),
              const SizedBox(height: 20),
              HlButton(
                label: 'Show confirmation',
                width: double.infinity,
                onPressed: () => HlFeedbackScope.of(context).confirm(
                  title: 'Confirm payment',
                  message: 'Continue with $_currency?',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
