import 'package:flutter/material.dart';

import 'color.dart';

/// 向子树提供 [HlFeedback] 实例的 InheritedWidget。
///
/// 通过 [HlFeedbackScope.of] 在任意子组件中获取反馈服务。
class HlFeedbackScope extends InheritedWidget {
  /// 创建一个反馈作用域。
  ///
  /// [feedback] 为向下传递的反馈服务实例。
  const HlFeedbackScope({
    super.key,
    required this.feedback,
    required super.child,
  });

  final HlFeedback feedback;

  /// 向上查找 [HlFeedback]，未找到时返回 `null`。
  static HlFeedback? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HlFeedbackScope>()?.feedback;

  /// 向上查找 [HlFeedback]，未找到时抛出 [StateError]。
  static HlFeedback of(BuildContext context) {
    final feedback = maybeOf(context);
    if (feedback == null) {
      throw StateError('No HlFeedbackScope found in the widget tree.');
    }
    return feedback;
  }

  @override
  bool updateShouldNotify(HlFeedbackScope oldWidget) =>
      feedback != oldWidget.feedback;
}

/// 全局反馈服务：弹窗、加载遮罩、SnackBar 提示的统一入口。
///
/// 依赖 [navigatorKey] 定位根 Navigator，依赖 [messengerKey] 展示
/// SnackBar（为 `null` 时提示类方法会抛出 [StateError]）。
class HlFeedback {
  /// 创建反馈服务。
  ///
  /// [navigatorKey] 为应用根 Navigator 的 [GlobalKey]，必须可解析；
  /// [messengerKey] 为 [ScaffoldMessenger] 的 [GlobalKey]，
  /// 为 `null` 时仅弹窗类方法可用。
  HlFeedback({required this.navigatorKey, this.messengerKey});

  static HlFeedback? _configured;

  /// 配置全局反馈实例，供 [HlFeedback.global] 使用。
  static void configure(HlFeedback feedback) => _configured = feedback;

  /// 获取全局反馈实例；未配置时抛出 [StateError]。
  static HlFeedback get global {
    final feedback = _configured;
    if (feedback == null) {
      throw StateError('HlFeedback must be configured before use.');
    }
    return feedback;
  }

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;

  BuildContext get _context {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw StateError('The application navigator is not ready.');
    }
    return context;
  }

  /// 弹出确认对话框，返回用户选择（`true` 确认 / `false` 取消）。
  ///
  /// [message] 为提示内容，[title] 为可选标题，[confirmLabel] /
  /// [cancelLabel] 为按钮文案；[showCancel] 为 `false` 时隐藏取消按钮。
  Future<bool?> confirm({
    required String message,
    String? title,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool showCancel = true,
  }) => showDialog<bool>(
    context: _context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: [
        if (showCancel)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  /// 弹出自定义样式的对话框，返回用户选择（`true` 确认 / `false` 取消）。
  ///
  /// 适用于请求失败等场景：[content] 为详情文本，[titleText] 为标题，
  /// [confirmText] / [cancelText] 为按钮与关闭图标文案。
  Future<bool?> openDialog({
    String content = '--',
    String? confirmText,
    String? cancelText,
    String? titleText,
  }) => showDialog<bool>(
    context: _context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: HlColor.bgWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: HlColor.bgErrorLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: HlColor.textError,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleText ?? 'Request failed',
                      style: TextStyle(
                        color: HlColor.textBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close_rounded, color: HlColor.textGrey),
                    tooltip: cancelText,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: TextStyle(
                      color: HlColor.textGrey,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: HlColor.mainDarkColor,
                    foregroundColor: HlColor.textWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(confirmText ?? 'OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// 展示一条普通的 SnackBar 消息。
  ///
  /// [backgroundColor] 覆盖默认背景色；需要 [messengerKey] 已配置，
  /// 否则抛出 [StateError]。
  void showMessage(String message, {Color? backgroundColor}) {
    final messenger = messengerKey?.currentState;
    if (messenger == null) {
      throw StateError('A ScaffoldMessenger key is required to show messages.');
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor),
      );
  }

  Route<void>? _loadingRoute;

  /// 展示全屏加载遮罩，重复调用不会叠加。
  ///
  /// [loadingWidget] 自定义加载内容，[dismissible] 为 `true` 时
  /// 允许点击遮罩关闭；通过 [closeAllLoading] 关闭。
  void showLoading({Widget? loadingWidget, bool dismissible = false}) {
    if (_loadingRoute != null) return;
    final route = DialogRoute<void>(
      context: _context,
      barrierDismissible: dismissible,
      builder: (_) => PopScope(
        canPop: dismissible,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: loadingWidget ?? const CircularProgressIndicator(),
          ),
        ),
      ),
    );
    _loadingRoute = route;
    _state.push<void>(route).whenComplete(() {
      if (identical(_loadingRoute, route)) _loadingRoute = null;
    });
  }

  /// 关闭当前加载遮罩。
  void closeAllLoading() {
    final route = _loadingRoute;
    if (route == null) return;
    _loadingRoute = null;
    if (route.isActive) {
      _state.removeRoute(route);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) _state.removeRoute(route);
      });
    }
  }

  NavigatorState get _state {
    final state = navigatorKey.currentState;
    if (state == null) {
      throw StateError('The application navigator is not ready.');
    }
    return state;
  }

  /// 展示成功态 SnackBar 提示。
  void successToast(String message) => _showStatusMessage(
    message,
    icon: Icons.check_circle_rounded,
    color: HlColor.textSuccess,
  );

  /// 展示警告态 SnackBar 提示。
  void warnToast(String message) => _showStatusMessage(
    message,
    icon: Icons.error_rounded,
    color: HlColor.textWarn,
  );

  /// 展示错误态 SnackBar 提示。
  void errorToast(String message) => _showStatusMessage(
    message,
    icon: Icons.cancel_rounded,
    color: HlColor.textError,
  );

  /// 展示一条可配置的通知型 SnackBar。
  ///
  /// [title] 与可选 [subtitle] 会合并为通知文本；[leading] 为前置图标，
  /// [duration] 控制展示时长，[onTap] 为点击回调。
  void notify({
    required String title,
    String? subtitle,
    Widget? leading,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    final message = subtitle == null ? title : '$title\n$subtitle';
    final messenger = messengerKey?.currentState;
    if (messenger == null) {
      throw StateError('A ScaffoldMessenger key is required to show messages.');
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: GestureDetector(
            onTap: () {
              messenger.hideCurrentSnackBar();
              onTap?.call();
            },
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 8)],
                Expanded(child: Text(message)),
              ],
            ),
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// 展示带状态图标的 SnackBar 内部实现。
  void _showStatusMessage(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    final messenger = messengerKey?.currentState;
    if (messenger == null) {
      throw StateError('A ScaffoldMessenger key is required to show messages.');
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// 关闭当前对话框，[result] 为对话框的返回值。
  void dismissDialog<T extends Object?>([T? result]) =>
      navigatorKey.currentState?.pop<T>(result);
}
