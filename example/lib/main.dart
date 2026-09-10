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
          child: const ComponentPreview(),
        ),
      ),
    );
  }
}

class ComponentPreview extends StatefulWidget {
  const ComponentPreview({super.key});

  @override
  State<ComponentPreview> createState() => _ComponentPreviewState();
}

class _ComponentPreviewState extends State<ComponentPreview> {
  String _currency = 'USD';
  Set<String> _networks = {'TRON'};
  bool _agree = false;
  bool _notify = true;
  final _controller = HlPagedController<String>(
    fetchPage: (request) async {
      await Future.delayed(const Duration(milliseconds: 400));
      final start = (request.page - 1) * request.pageSize;
      return HlPageData(
        items: List.generate(
          request.pageSize,
          (i) => 'Item ${start + i + 1}',
        ),
        page: request.page,
        pageSize: request.pageSize,
        total: 35,
      );
    },
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('hl_ui'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Basic'),
              Tab(text: 'Buttons'),
              Tab(text: 'Forms'),
              Tab(text: 'Feedback'),
              Tab(text: 'PagedList'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBasic(context),
            _buildButtons(context),
            _buildForms(context),
            _buildFeedback(context),
            _buildPagedList(),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _buildBasic(BuildContext context) => ListView(
    children: [
      _section('HlCard', [
        const HlCard(
          child: Text('Tap me (onTap null, no ripple)'),
        ),
        const SizedBox(height: 12),
        HlCard(
          onTap: () => HlFeedbackScope.of(context).successToast('Card tapped'),
          child: const Text('Tap me (with ripple)'),
        ),
      ]),
      _section('HlBadge', [
        const Wrap(
          spacing: 8,
          children: [
            HlBadge(label: 'Active'),
            HlBadge(label: 'Pending', color: Colors.amber),
            HlBadge(label: 'Error', color: Colors.red, foregroundColor: Colors.white),
          ],
        ),
      ]),
      _section('HlAvatar', [
        const Row(
          children: [
            HlAvatar(label: 'John Doe'),
            SizedBox(width: 12),
            HlAvatar(label: 'Jane', size: 48, backgroundColor: Colors.blue),
            SizedBox(width: 12),
            HlAvatar(label: ''),
          ],
        ),
      ]),
      _section('HlDivider & HlIconButton', [
        HlIconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () => HlFeedbackScope.of(context).successToast('Refreshed'),
        ),
        const HlDivider(),
        const Text('Above is a HlDivider'),
      ]),
      _section('HlStatusView', [
        HlStatusView(
          icon: Icons.inbox_outlined,
          title: 'No items',
          message: 'Add your first item to get started',
          actionLabel: 'Create',
          onAction: () => HlFeedbackScope.of(context).successToast('Create tapped'),
        ),
      ]),
      _section('HlLoadingView', [
        const SizedBox(height: 80, child: HlLoadingView(label: 'Loading...')),
      ]),
      _section('Extensions (padding / text)', [
        Container(
          color: Colors.blue.shade50,
          child: 'Hello'.text(18, weight: FontWeight.w700).p(16),
        ),
      ]),
    ],
  );

  Widget _buildButtons(BuildContext context) => ListView(
    children: [
      _section('Variants', [
        HlButton(label: 'Filled', onPressed: () {}).pb(8),
        HlButton(label: 'Tonal', variant: HlButtonVariant.tonal, onPressed: () {}).pb(8),
        HlButton(label: 'Outlined', variant: HlButtonVariant.outlined, onPressed: () {}).pb(8),
        HlButton(label: 'Text', variant: HlButtonVariant.text, onPressed: () {}).pb(8),
        HlButton(label: 'Danger', variant: HlButtonVariant.danger, onPressed: () {}).pb(8),
        const HlButton(label: 'Disabled', onPressed: null),
      ]),
      _section('Sizes', [
        HlButton(label: 'Small', size: HlButtonSize.small, onPressed: () {}).pb(8),
        HlButton(label: 'Medium', size: HlButtonSize.medium, onPressed: () {}).pb(8),
        HlButton(label: 'Large', size: HlButtonSize.large, onPressed: () {}),
      ]),
      _section('With icons & loading', [
        HlButton(
          label: 'With leading',
          leading: const Icon(Icons.add, size: 18),
          onPressed: () {},
        ).pb(8),
        HlButton(
          label: 'With trailing',
          trailing: const Icon(Icons.arrow_forward, size: 18),
          onPressed: () {},
        ).pb(8),
        HlButton(label: 'Loading...', isLoading: true, onPressed: () {}),
      ]),
    ],
  );

  Widget _buildForms(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      HlTextField(
        label: 'Username',
        hint: 'Enter username',
        prefixIcon: const Icon(Icons.person_outline),
      ).pb(16),
      HlTextField(
        label: 'Password',
        obscureText: true,
        prefixIcon: const Icon(Icons.lock_outline),
      ).pb(16),
      HlSelectField(
        label: 'Currency',
        value: _currency,
        options: const [
          HlSelectOption(value: 'USD', label: 'USD'),
          HlSelectOption(value: 'MYR', label: 'MYR'),
          HlSelectOption(value: 'SGD', label: 'SGD'),
        ],
        onChanged: (v) => setState(() => _currency = v ?? 'USD'),
      ).pb(16),
      HlChoiceGroup(
        multiSelect: true,
        values: _networks,
        options: const [
          HlChoiceOption(value: 'TRON', label: 'TRON'),
          HlChoiceOption(value: 'ETH', label: 'Ethereum'),
          HlChoiceOption(value: 'BTC', label: 'Bitcoin'),
        ],
        onChanged: (v) => setState(() => _networks = v),
      ).pb(16),
      HlCheckboxField(
        label: 'I agree to the terms',
        value: _agree,
        onChanged: (v) => setState(() => _agree = v ?? false),
      ).pb(8),
      HlSwitchField(
        label: 'Enable notifications',
        value: _notify,
        onChanged: (v) => setState(() => _notify = v),
      ).pb(8),
      const HlTextField(
        label: 'Disabled field',
        enabled: false,
        hint: 'Cannot edit',
      ),
    ],
  );

  Widget _buildFeedback(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      HlButton(
        label: 'showLoading (2s)',
        width: double.infinity,
        onPressed: () async {
          final feedback = HlFeedbackScope.of(context);
          feedback.showLoading();
          await Future.delayed(const Duration(seconds: 2));
          feedback.closeAllLoading();
        },
      ).pb(8),
      HlButton(
        label: 'notify (tap me)',
        variant: HlButtonVariant.tonal,
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).notify(
          title: 'Payment received',
          subtitle: '1.00 USDT on TRON',
          leading: const Icon(Icons.check_circle, color: Colors.green),
          onTap: () => HlFeedbackScope.of(context).successToast('Opened detail'),
        ),
      ).pb(8),
      HlButton(
        label: 'successToast',
        variant: HlButtonVariant.outlined,
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).successToast('Saved successfully'),
      ).pb(8),
      HlButton(
        label: 'warnToast',
        variant: HlButtonVariant.outlined,
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).warnToast('Low balance'),
      ).pb(8),
      HlButton(
        label: 'errorToast',
        variant: HlButtonVariant.outlined,
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).errorToast('Request failed'),
      ).pb(8),
      HlButton(
        label: 'confirm dialog',
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).confirm(
          title: 'Confirm',
          message: 'Are you sure?',
        ),
      ).pb(8),
      HlButton(
        label: 'openDialog (error style)',
        variant: HlButtonVariant.danger,
        width: double.infinity,
        onPressed: () => HlFeedbackScope.of(context).openDialog(
          titleText: 'Request failed',
          content: 'The server returned an error. Please try again.',
        ),
      ),
    ],
  );

  Widget _buildPagedList() => HlPagedList<String>(
    controller: _controller,
    padding: const EdgeInsets.all(16),
    itemBuilder: (context, item, index) => HlCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(item),
    ).onGestureTap(() {}),
    emptyBuilder: (_) => const HlStatusView(
      icon: Icons.inbox_outlined,
      title: 'No data',
    ),
  );
}
