import 'dart:collection';

import 'package:flutter/material.dart';

/// 一页数据的结果抽象。
///
/// 由 [HlPagedController.fetchPage] 返回，描述当页条目、
/// 页码与每页大小。[total] 为可选的总条目数，提供时控制器
/// 会优先用它判断是否还有更多数据。
abstract interface class HlPage<T> {
  /// 当页的条目列表。
  List<T> get items;

  /// 当前页码，从 1 开始。
  int get page;

  /// 每页条目数。
  int get pageSize;

  /// 总条目数；为 `null` 时控制器回退为按 `items.length >= pageSize`
  /// 判断是否还有更多数据。
  int? get total;
}

/// [HlPage] 的默认不可变实现。
class HlPageData<T> implements HlPage<T> {
  /// 创建一页数据。
  ///
  /// - [items]: 当页的条目列表。
  /// - [page]: 当前页码，从 1 开始。
  /// - [pageSize]: 每页条目数。
  /// - [total]: 总条目数，可选。
  const HlPageData({
    required this.items,
    required this.page,
    required this.pageSize,
    this.total,
  });

  @override
  final List<T> items;

  @override
  final int page;

  @override
  final int pageSize;

  @override
  final int? total;
}

/// 分页请求参数，由 [HlPagedController] 构造后传给 [HlPagedController.fetchPage]。
@immutable
class HlPageRequest {
  /// 创建分页请求。
  ///
  /// - [page]: 请求的页码，从 1 开始。
  /// - [pageSize]: 每页条目数。
  /// - [query]: 附加的查询条件，透传给数据源。
  const HlPageRequest({
    required this.page,
    required this.pageSize,
    this.query = const {},
  });

  /// 请求的页码。
  final int page;

  /// 每页条目数。
  final int pageSize;

  /// 附加的查询条件，透传给数据源。
  final Map<String, Object?> query;
}

/// 分页数据控制器，基于 [ChangeNotifier] 管理列表加载状态。
///
/// 通过 [loadFirst] / [loadNext] / [retry] 驱动数据加载，UI 订阅
/// [items] / [isLoading] / [error] 等状态渲染列表。
///
/// 内部实现了请求竞态保护与 disposed 防护：controller 被释放后，
/// 所有公开方法调用与迟到请求回调都会被安全忽略，不会抛
/// "used after being disposed" 异常。
class HlPagedController<T> extends ChangeNotifier {
  /// 创建分页控制器。
  ///
  /// - [fetchPage]: 分页数据源，接收 [HlPageRequest] 返回一页数据。
  /// - [pageSize]: 每页条目数，必须大于 0。
  HlPagedController({required this.fetchPage, this.pageSize = 20})
    : assert(pageSize > 0);

  /// 分页数据源。
  final Future<HlPage<T>> Function(HlPageRequest request) fetchPage;

  /// 每页条目数。
  final int pageSize;

  final List<T> _items = [];
  Map<String, Object?> _query = const {};
  var _nextPage = 1;
  var hasMore = true;
  var _activeRequests = 0;
  var _revision = 0;
  var _disposed = false;
  Object? error;

  /// 已加载条目的只读视图。
  UnmodifiableListView<T> get items => UnmodifiableListView(_items);

  /// 当前是否没有任何条目。
  bool get isEmpty => _items.isEmpty;

  /// 最近一次加载是否出错。
  bool get hasError => error != null;

  /// 是否正在加载中（存在进行中的请求）。
  bool get isLoading => _activeRequests > 0;

  /// 控制器是否已被释放。
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }

  /// 向监听者广播状态变更；已释放时静默忽略。
  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  /// 加载第一页，可同时重置查询条件。
  ///
  /// 会清空现有条目并将页码重置为 1；已释放时直接返回。
  ///
  /// - [query]: 新的查询条件；加载期间再次调用会以最新条件为准。
  Future<void> loadFirst({Map<String, Object?> query = const {}}) async {
    if (_disposed) return;
    final revision = ++_revision;
    _query = Map.unmodifiable(query);
    _nextPage = 1;
    _items.clear();
    hasMore = true;
    await _loadPage(replace: true, revision: revision);
  }

  /// 加载下一页（触底加载）。
  ///
  /// 加载中或没有更多数据时直接返回；已释放时直接返回。
  Future<void> loadNext() async {
    if (_disposed || isLoading || !hasMore) return;
    await _loadPage(replace: false, revision: _revision);
  }

  /// 重试最近一次失败的加载。
  ///
  /// 列表为空时按首屏加载处理，否则加载下一页；已释放时直接返回。
  Future<void> retry() {
    if (_disposed) return Future<void>.value();
    return _loadPage(replace: _items.isEmpty, revision: _revision);
  }

  /// 加载一页数据的内部实现。
  ///
  /// - [replace]: 为 `true` 时先清空已有条目（首屏/刷新），否则追加。
  /// - [revision]: 发起时的修订号，用于丢弃过期请求的结果。
  Future<void> _loadPage({required bool replace, required int revision}) async {
    if (_disposed ||
        (!replace && (isLoading || !hasMore)) ||
        revision != _revision) {
      return;
    }
    _activeRequests++;
    error = null;
    _notifyListeners();
    try {
      final page = await fetchPage(
        HlPageRequest(page: _nextPage, pageSize: pageSize, query: _query),
      );
      if (_disposed) return;
      if (revision == _revision) {
        if (replace) _items.clear();
        _items.addAll(page.items);
        final pageTotal = page.total;
        hasMore = pageTotal != null
            ? _items.length < pageTotal
            : page.items.length >= pageSize;
        if (hasMore) _nextPage++;
      }
    } catch (exception) {
      if (!_disposed && revision == _revision) error = exception;
    } finally {
      _activeRequests--;
      _notifyListeners();
    }
  }
}

/// 与 [HlPagedController] 绑定的分页列表组件。
///
/// 负责滚动加载、下拉刷新、空态/错误/加载态展示；
/// [loadOnMount] 为 `true` 时挂载后自动加载第一页。
class HlPagedList<T> extends StatefulWidget {
  /// 创建分页列表。
  ///
  /// - [controller]: 分页控制器，列表状态由它驱动。
  /// - [itemBuilder]: 条目构建器，接收条目与索引返回列表项。
  /// - [padding]: 列表内边距。
  /// - [scrollController]: 外部滚动控制器；不传时内部自动创建。
  /// - [emptyBuilder]: 空数据时的占位内容；不传时显示空组件。
  /// - [errorBuilder]: 加载失败时的占位内容，接收错误对象。
  /// - [loadingBuilder]: 加载中的占位内容。
  /// - [loadOnMount]: 挂载后是否自动加载第一页，默认 `true`。
  /// - [loadMoreThreshold]: 距底部多少像素时触发加载下一页，默认 200。
  const HlPagedList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.padding,
    this.scrollController,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.loadOnMount = true,
    this.loadMoreThreshold = 200,
  });

  /// 分页控制器。
  final HlPagedController<T> controller;

  /// 条目构建器。
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 列表内边距。
  final EdgeInsetsGeometry? padding;

  /// 外部滚动控制器。
  final ScrollController? scrollController;

  /// 空数据占位内容。
  final WidgetBuilder? emptyBuilder;

  /// 加载失败占位内容，接收错误对象。
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// 加载中占位内容。
  final WidgetBuilder? loadingBuilder;

  /// 挂载后是否自动加载第一页。
  final bool loadOnMount;

  /// 距底部多少像素时触发加载下一页。
  final double loadMoreThreshold;

  @override
  State<HlPagedList<T>> createState() => _HlPagedListState<T>();
}

class _HlPagedListState<T> extends State<HlPagedList<T>> {
  late ScrollController _scrollController;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _setScrollController();
    if (widget.loadOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 首帧回调无法取消，需确认组件仍挂载再触发加载，
        // 避免对已释放 controller 发起请求。
        if (mounted) widget.controller.loadFirst();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HlPagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController.removeListener(_loadWhenNearEnd);
      if (_ownsController) {
        _scrollController.dispose();
      }
      _setScrollController();
    }
  }

  /// 初始化滚动控制器并挂载滚动监听。
  void _setScrollController() {
    _ownsController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_loadWhenNearEnd);
  }

  /// 滚动接近底部时加载下一页。
  void _loadWhenNearEnd() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <=
        widget.loadMoreThreshold) {
      widget.controller.loadNext();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadWhenNearEnd);
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        if (controller.isEmpty && controller.isLoading) {
          return _loading(context);
        }
        if (controller.isEmpty && controller.error != null) {
          return _error(context, controller.error!);
        }
        if (controller.isEmpty) {
          return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
        }
        return RefreshIndicator(
          onRefresh: controller.loadFirst,
          child: ListView.builder(
            controller: _scrollController,
            padding: widget.padding,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.items.length + 1,
            itemBuilder: (context, index) {
              if (index < controller.items.length) {
                return widget.itemBuilder(
                  context,
                  controller.items[index],
                  index,
                );
              }
              if (controller.error != null) {
                return _error(context, controller.error!);
              }
              if (controller.hasMore || controller.isLoading) {
                return _loading(context);
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  /// 构建加载中占位内容。
  Widget _loading(BuildContext context) =>
      widget.loadingBuilder?.call(context) ??
      const Center(child: CircularProgressIndicator());

  /// 构建错误占位内容，默认提供重试按钮。
  Widget _error(BuildContext context, Object error) => Center(
    child:
        widget.errorBuilder?.call(context, error) ??
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error.toString()),
            TextButton(
              onPressed: widget.controller.retry,
              child: const Text('Retry'),
            ),
          ],
        ),
  );
}
