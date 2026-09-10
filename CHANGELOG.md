## 1.0.2

- Fixed `HlFeedback.showLoading` missing `Material` ancestor, which caused yellow text underlines in custom loading widgets.
- Fixed `HlFeedback.notify` not dismissing the SnackBar on tap, allowing repeated callback triggers.
- Fixed race condition in `HlFeedback.showLoading`/`closeAllLoading` where closing before the route finished pushing could leave the loading overlay permanently visible.
- Added optional `total` to `HlPage`; `HlPagedController` now uses it to determine `hasMore` when available, avoiding redundant empty-page requests.
- Fixed `HlPagedList` pull-to-refresh not working when the list content is shorter than one screen.
- Added `loadMoreThreshold` parameter to `HlPagedList` for configurable infinite-scroll trigger distance.
- Made `HlThemeData.success` and `warning` configurable via constructor.
- Fixed `HlIcon` network SVG having no error fallback and no request timeout (now uses `HttpClient` with 10s timeouts and `errorWidget` support).
- Added click cursor and semantics label to tappable `HlIcon`.
- Fixed `HlSelectField` disabled state lacking visual feedback (now 50% opacity).
- Added assertion that `HlStatusView.actionLabel` and `onAction` are both set or both null.

## 1.0.1

- Updated copyright holder to Evan Han in LICENSE.

## 1.0.0

- First stable public release of `hl_ui`.
- Theme tokens, controls, forms, feedback, and paged-list APIs are now stable.
