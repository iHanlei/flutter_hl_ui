import 'package:flutter/material.dart';

/// 应用主题数据，封装 [ColorScheme] 与间距、圆角、密度配置。
@immutable
class HlThemeData {
  /// 创建主题数据。
  ///
  /// [colorScheme] 为 Material 配色，[spacing] / [radii] 为间距与圆角
  /// 标尺，[density] 为组件密度，[success] / [warning] 为状态色
  /// （不传时使用默认绿色/琥珀色）。
  const HlThemeData({
    required this.colorScheme,
    this.spacing = const HlSpacing(),
    this.radii = const HlRadii(),
    this.density = VisualDensity.standard,
    this.success = const Color(0xFF059669),
    this.warning = const Color(0xFFD97706),
  });

  final ColorScheme colorScheme;
  final HlSpacing spacing;
  final HlRadii radii;
  final VisualDensity density;
  final Color success;
  final Color warning;

  /// 从 Material [ThemeData] 派生主题数据。
  ///
  /// 继承其 [ColorScheme] 与密度，间距与圆角使用默认标尺。
  factory HlThemeData.fromMaterial(ThemeData theme) =>
      HlThemeData(colorScheme: theme.colorScheme, density: theme.visualDensity);

  /// 表面色。
  Color get surface => colorScheme.surface;

  /// 页面背景色。
  Color get background => colorScheme.surfaceContainerLowest;

  /// 主文字色。
  Color get textPrimary => colorScheme.onSurface;

  /// 次级文字色。
  Color get textSecondary => colorScheme.onSurfaceVariant;

  /// 描边色。
  Color get border => colorScheme.outlineVariant;
}

/// 间距标尺。
@immutable
class HlSpacing {
  /// 创建间距标尺。
  ///
  /// [xs] 至 [xxl] 为从 4 到 32 的递增档位。
  const HlSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
}

/// 圆角标尺。
@immutable
class HlRadii {
  /// 创建圆角标尺。
  ///
  /// [sm] / [md] / [lg] 为常规圆角档位，[pill] 为胶囊形圆角。
  const HlRadii({this.sm = 8, this.md = 12, this.lg = 16, this.pill = 999});

  final double sm;
  final double md;
  final double lg;
  final double pill;
}

/// 向下传递 [HlThemeData] 的 InheritedTheme。
class HlTheme extends InheritedTheme {
  /// 创建主题作用域。
  ///
  /// [data] 为要传递的主题数据。
  const HlTheme({super.key, required this.data, required super.child});

  final HlThemeData data;

  /// 向上获取 [HlThemeData]。
  ///
  /// 树上没有 [HlTheme] 时回退为从 Material [ThemeData] 派生。
  static HlThemeData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<HlTheme>();
    return inherited?.data ?? HlThemeData.fromMaterial(Theme.of(context));
  }

  @override
  bool updateShouldNotify(HlTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      HlTheme(data: data, child: child);
}

/// 从 [BuildContext] 便捷获取 [HlThemeData] 的扩展。
extension HlThemeContext on BuildContext {
  /// 当前上下文所属的主题数据。
  HlThemeData get hlTheme => HlTheme.of(this);
}
