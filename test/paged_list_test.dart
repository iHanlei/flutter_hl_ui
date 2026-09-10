import 'dart:async';

import 'package:flutter/material.dart';
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

  test('uses total to determine hasMore when provided', () async {
    final controller = HlPagedController<int>(
      pageSize: 2,
      fetchPage: (request) async => _Page(
        request.page == 1 ? [1, 2] : [3],
        page: request.page,
        pageSize: 2,
        total: 3,
      ),
    );

    await controller.loadFirst();
    // 第一页返回 2 条但 total=3，hasMore 应为 true
    expect(controller.hasMore, isTrue);
    await controller.loadNext();
    // 加载完 3 条后 hasMore 应为 false
    expect(controller.items, [1, 2, 3]);
    expect(controller.hasMore, isFalse);
  });

  testWidgets('renders the no-more footer after every page is loaded', (
    tester,
  ) async {
    final controller = HlPagedController<int>(
      fetchPage: (_) async => const _Page([1], page: 1, pageSize: 20),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 300,
          child: HlPagedList<int>(
            controller: controller,
            loadOnMount: false,
            itemBuilder: (_, item, _) => Text('$item'),
            noMoreBuilder: (_) => const Text('No more data'),
          ),
        ),
      ),
    );

    await controller.loadFirst();
    await tester.pump();

    expect(find.text('No more data'), findsOneWidget);
  });
}

class _Page implements HlPage<int> {
  const _Page(
    this.items, {
    required this.page,
    required this.pageSize,
    this.total,
  });

  @override
  final List<int> items;

  @override
  final int page;

  @override
  final int pageSize;

  @override
  final int? total;
}
