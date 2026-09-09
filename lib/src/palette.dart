import 'package:flutter/material.dart';

/// 一套完整的主题色板。
///
/// 由 [HlThemeData] 引用，业务组件据此统一取色。
@immutable
class HlPalette {
  /// 创建主题色板。
  ///
  /// [primary] 为主色，[surface] / [background] 为表面与背景色，
  /// [textPrimary] / [textSecondary] 为文字色，[border] 为描边色，
  /// [error] / [success] / [warning] 为状态色。
  const HlPalette({
    required this.primary,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
  });

  final Color primary;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;
}
