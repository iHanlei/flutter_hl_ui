import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hl_ui/hl_ui.dart';

void main() {
  test('loads pages once and retries the failed page', () async {
    var attempts = 0;
    final controller = HlPagedController<int>(
      pageSize: 2,
      fetchPage: (request) async {
        attempts++;
        if (request.page == 2 && attempts == 2) throw StateError('offline');
        return _Page(
          request.page == 1 ? [1, 2] : [3],
          page: request.page,
          pageSize: 2,
        );
      },
    );

    await controller.loadFirst();
    await controller.loadNext();
    expect(controller.items, [1, 2]);
    expect(controller.hasError, isTrue);

    await controller.retry();
    expect(controller.items, [1, 2, 3]);
    expect(controller.hasMore, isFalse);
    expect(attempts, 3);
  });

  test('ignores stale refresh results', () async {
    final responses = <Completer<HlPage<int>>>[];
    final controller = HlPagedController<int>(
      fetchPage: (_) {
        final response = Completer<HlPage<int>>();
        responses.add(response);
        return response.future;
      },
    );

    final first = controller.loadFirst();
    final second = controller.loadFirst();
    responses[1].complete(const _Page([2], page: 1, pageSize: 20));
    await second;
    responses[0].complete(const _Page([1], page: 1, pageSize: 20));
    await first;

    expect(controller.items, [2]);
  });
}

class _Page implements HlPage<int> {
  const _Page(this.items, {required this.page, required this.pageSize});

  @override
  final List<int> items;

  @override
  final int page;

  @override
  final int pageSize;
}
