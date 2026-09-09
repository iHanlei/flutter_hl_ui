import 'package:flutter/material.dart';

import 'theme.dart';

/// 按钮样式变体。
enum HlButtonVariant {
  /// 实心填充按钮。
  filled,

  /// 柔和色调按钮。
  tonal,

  /// 描边按钮。
  outlined,

  /// 纯文本按钮。
  text,

  /// 危险操作按钮（错误色）。
  danger,
}

/// 按钮尺寸档位。
enum HlButtonSize {
  /// 小号按钮，高度 36。
  small,

  /// 中号按钮，高度 44。
  medium,

  /// 大号按钮，高度 52。
  large,
}

/// 主题化按钮，支持多变体、图标、加载态与无障碍标签。
///
/// [onPressed] 为 `null` 或 [isLoading] 为 `true` 时按钮处于禁用态。
class HlButton extends StatelessWidget {
  /// 创建一个按钮。
  ///
  /// [label] 为按钮文案；[onPressed] 为点击回调，为 `null` 时禁用；
  /// [leading] / [trailing] 为前置/后置图标；[variant] 与 [size] 控制
  /// 样式变体与尺寸；[isLoading] 为 `true` 时展示加载圈并禁用点击；
  /// [unfocusOnPressed] 控制点击时是否收起键盘焦点；
  /// [semanticsLabel] 覆盖无障碍标签，其余参数覆盖对应默认样式。
  const HlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.radius,
    this.unfocusOnPressed = true,
    this.trailing,
    this.variant = HlButtonVariant.filled,
    this.size = HlButtonSize.medium,
    this.isLoading = false,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double? radius;
  final bool unfocusOnPressed;
  final Widget? trailing;
  final HlButtonVariant variant;
  final HlButtonSize size;
  final bool isLoading;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    final colorScheme = theme.colorScheme;
    final buttonHeight =
        height ??
        switch (size) {
          HlButtonSize.small => 36.0,
          HlButtonSize.medium => 44.0,
          HlButtonSize.large => 52.0,
        };
    final isEnabled = onPressed != null && !isLoading;
    final callback = isEnabled
        ? () {
            if (unfocusOnPressed) FocusManager.instance.primaryFocus?.unfocus();
            onPressed!();
          }
        : null;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foreground(colorScheme),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        if (trailing != null && !isLoading) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticsLabel ?? label,
      child: SizedBox(
        width: width,
        height: buttonHeight,
        child: _buildButton(
          callback: callback,
          child: child,
          colorScheme: colorScheme,
          radius: radius ?? theme.radii.md,
        ),
      ),
    );
  }

  /// 按变体构建对应的 Material 按钮实例。
  Widget _buildButton({
    required VoidCallback? callback,
    required Widget child,
    required ColorScheme colorScheme,
    required double radius,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final background = backgroundColor ?? _background(colorScheme);
    final foreground = foregroundColor ?? _foreground(colorScheme);
    return switch (variant) {
      HlButtonVariant.outlined => OutlinedButton(
        onPressed: callback,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: backgroundColor ?? colorScheme.outline),
          shape: shape,
        ),
        child: child,
      ),
      HlButtonVariant.text => TextButton(
        onPressed: callback,
        style: TextButton.styleFrom(foregroundColor: foreground, shape: shape),
        child: child,
      ),
      HlButtonVariant.filled ||
      HlButtonVariant.tonal ||
      HlButtonVariant.danger => FilledButton(
        onPressed: callback,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: shape,
        ),
        child: child,
      ),
    };
  }

  /// 计算当前变体的默认背景色。
  Color _background(ColorScheme scheme) => switch (variant) {
    HlButtonVariant.filled => scheme.primary,
    HlButtonVariant.tonal => scheme.secondaryContainer,
    HlButtonVariant.danger => scheme.error,
    HlButtonVariant.outlined || HlButtonVariant.text => Colors.transparent,
  };

  /// 计算当前变体的默认前景色（文字/图标色）。
  Color _foreground(ColorScheme scheme) => switch (variant) {
    HlButtonVariant.filled => scheme.onPrimary,
    HlButtonVariant.tonal => scheme.onSecondaryContainer,
    HlButtonVariant.danger => scheme.onError,
    HlButtonVariant.outlined || HlButtonVariant.text => scheme.primary,
  };
}
