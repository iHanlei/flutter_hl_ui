import 'package:flutter/material.dart';

/// 基础样式工具。
class HlStyles {
  HlStyles._();

  /// 创建基础 [TextStyle]。
  ///
  /// [fontSize] 为字号，[color] / [weight] 控制颜色与字重。
  static TextStyle text(double fontSize, {Color? color, FontWeight? weight}) =>
      TextStyle(fontSize: fontSize, color: color, fontWeight: weight);

  /// 创建圆角背景装饰。
  ///
  /// [color] 为背景色，[radius] 为圆角半径，[boxShadow] 为可选阴影。
  static BoxDecoration rounded({
    required Color color,
    double radius = 8,
    List<BoxShadow>? boxShadow,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: boxShadow,
  );
}

/// 常用样式的静态速查。
class HlStyle {
  HlStyle._();

  /// 14 号常规文本样式。
  static TextStyle get text14 => HlStyles.text(14);

  /// 8 圆角、纯色背景装饰。
  static BoxDecoration toBoxR8({required Color color}) =>
      HlStyles.rounded(color: color, radius: 8);

  /// 16 圆角、纯色背景装饰。
  static BoxDecoration toBoxR16({required Color color}) =>
      HlStyles.rounded(color: color, radius: 16);
}
