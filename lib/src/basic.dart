import 'package:flutter/material.dart';

import 'theme.dart';

/// 主题化卡片容器，可选点击反馈与圆角描边。
///
/// 点击回调 [onTap] 为 `null` 时无点击反馈。
class HlCard extends StatelessWidget {
  /// 创建一个卡片容器。
  ///
  /// [child] 为卡片内容，[padding] / [margin] 控制内边距与外边距，
  /// [onTap] 为点击回调，[color] 覆盖默认背景色，[elevation] 为阴影高度。
  const HlCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    return Card(
      margin: margin,
      elevation: elevation,
      color: color ?? theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        side: BorderSide(color: theme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing.lg),
          child: child,
        ),
      ),
    );
  }
}

/// 主题化徽标，用于数量、状态等短文本标记。
class HlBadge extends StatelessWidget {
  /// 创建一个徽标。
  ///
  /// [label] 为展示文本，[color] / [foregroundColor] 覆盖默认背景色与文字色。
  const HlBadge({
    super.key,
    required this.label,
    this.color,
    this.foregroundColor,
  });

  final String label;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(theme.radii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foregroundColor ?? theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 主题化头像，支持图片与文字标签两种模式。
///
/// 无图片时展示 [label] 的首字母，[label] 为空时展示 `?`。
class HlAvatar extends StatelessWidget {
  /// 创建一个头像。
  ///
  /// [image] 为头像图片来源，[label] 为无障碍标签及文字模式的首字符，
  /// [size] 为直径，[backgroundColor] / [foregroundColor] 覆盖默认配色。
  const HlAvatar({
    super.key,
    this.image,
    this.label,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
  });

  final ImageProvider<Object>? image;
  final String? label;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    return Semantics(
      label: label,
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor:
            backgroundColor ?? theme.colorScheme.secondaryContainer,
        foregroundImage: image,
        child: Text(
          label?.isEmpty == false ? label![0].toUpperCase() : '?',
          style: TextStyle(
            color: foregroundColor ?? theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// 主题化分割线。
class HlDivider extends StatelessWidget {
  /// 创建一条分割线。
  ///
  /// [indent] / [endIndent] 为左右缩进，[height] 同时决定高度与线宽。
  const HlDivider({super.key, this.indent, this.endIndent, this.height = 1});

  final double? indent;
  final double? endIndent;
  final double height;

  @override
  Widget build(BuildContext context) => Divider(
    height: height,
    thickness: height,
    indent: indent,
    endIndent: endIndent,
    color: context.hlTheme.border,
  );
}

/// 主题化图标按钮，提供无障碍提示。
class HlIconButton extends StatelessWidget {
  /// 创建一个图标按钮。
  ///
  /// [icon] 为图标内容，[tooltip] 为无障碍提示（必填），
  /// [onPressed] 为点击回调，[color] 覆盖默认图标颜色。
  const HlIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    color: color ?? context.hlTheme.textPrimary,
    icon: icon,
  );
}

/// 通用状态视图，用于空态、加载失败等场景展示。
///
/// 通过 [icon] / [title] / [message] 组合展示信息，
/// 通过 [actionLabel] + [onAction] 提供可选的操作按钮。
class HlStatusView extends StatelessWidget {
  /// 创建一个状态视图。
  ///
  /// [title] 为主文案，[message] 为副文案，[icon] 为顶部图标，
  /// [actionLabel] 与 [onAction] 成对出现，控制操作按钮。
  const HlStatusView({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.padding,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'actionLabel and onAction must be both set or both null',
        );

  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 40, color: theme.textSecondary),
                SizedBox(height: theme.spacing.md),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: theme.spacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: theme.textSecondary),
                ),
              ],
              if (onAction != null && actionLabel != null) ...[
                SizedBox(height: theme.spacing.lg),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 居中的加载视图，可选说明文字。
class HlLoadingView extends StatelessWidget {
  /// 创建一个加载视图。
  ///
  /// [label] 为可选说明文字，同时作为无障碍标签。
  const HlLoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label ?? 'Loading',
    liveRegion: true,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[const SizedBox(height: 12), Text(label!)],
        ],
      ),
    ),
  );
}
