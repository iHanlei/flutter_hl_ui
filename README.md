# hl_ui

Theme-driven Flutter components for product teams building forms, feedback
flows, and paged data views. The package has no application assets, routes, or
business copy.

## What is included

- Theme tokens: `HlThemeData`, spacing, radii, and semantic color access.
- Controls: `HlButton`, icon button, badge, avatar, card, divider, and status views.
- Forms: text field, select field, checkbox, switch, and single/multi-choice chips.
- Feedback: scoped or key-based dialogs, confirmations, notifications, and loading.
- Data: selection controller and guarded pull-to-refresh/infinite pagination.

## Setup

```dart
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
final feedback = HlFeedback(
  navigatorKey: navigatorKey,
  messengerKey: messengerKey,
);

MaterialApp(
  navigatorKey: navigatorKey,
  scaffoldMessengerKey: messengerKey,
  builder: (_, child) => HlTheme(
    data: HlThemeData.fromMaterial(ThemeData.light()),
    child: HlFeedbackScope(feedback: feedback, child: child!),
  ),
);
```

Use `HlFeedbackScope.of(context)` in widgets. `HlFeedback.global` remains for
existing applications that configure a single root feedback instance.

## Design rules

- Consumer applications provide localized strings, assets, and domain logic.
- Prefer `HlTheme` over the legacy mutable `HlColor` compatibility API.
- Keep loading, empty, and error states explicit with `HlStatusView` or custom
  builders in `HlPagedList`.

Run `flutter analyze` and `flutter test` in this package before publishing.
