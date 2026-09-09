import 'package:flutter/material.dart';

import 'color.dart';

/// Widget 布局与交互的便捷扩展。
extension HlWidgetPadding on Widget {
  /// 将当前 Widget 包裹进 [Expanded]。
  Widget get expanded => Expanded(child: this);

  /// 将当前 Widget 右对齐。
  Widget get right => Align(alignment: Alignment.centerRight, child: this);

  /// 包一层带水波纹反馈的 [InkWell]。
  ///
  /// [callback] 为点击回调，[decoration] 为水波纹区域的装饰
  /// （会据此推导圆角）。
  Ink onInkTap(GestureTapCallback? callback, {BoxDecoration? decoration}) =>
      Ink(
        decoration: decoration,
        child: InkWell(
          onTap: callback,
          borderRadius: decoration?.borderRadius is BorderRadius
              ? decoration!.borderRadius as BorderRadius
              : null,
          child: this,
        ),
      );

  /// 包一层点击手势与手型光标。
  ///
  /// [callback] 为 `null` 时仍拦截触摸但无点击反馈，光标保持默认。
  MouseRegion onGestureTap(GestureTapCallback? callback) => MouseRegion(
    cursor: callback == null ? MouseCursor.defer : SystemMouseCursors.click,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: callback,
      child: this,
    ),
  );

  /// 四周统一内边距。
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// 顶部内边距。
  Widget padTop(double value) => Padding(
    padding: EdgeInsets.only(top: value),
    child: this,
  );

  /// 底部内边距。
  Widget padBottom(double value) => Padding(
    padding: EdgeInsets.only(bottom: value),
    child: this,
  );

  /// 左侧内边距。
  Widget padLeft(double value) => Padding(
    padding: EdgeInsets.only(left: value),
    child: this,
  );

  /// 右侧内边距。
  Widget padRight(double value) => Padding(
    padding: EdgeInsets.only(right: value),
    child: this,
  );

  /// 水平方向内边距。
  Widget padHorizontal(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );

  /// 垂直方向内边距。
  Widget padVertical(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );

  /// 四周统一内边距的缩写。
  Widget p(double value) => padAll(value);

  /// 顶部内边距的缩写。
  Widget pt(double value) => padTop(value);

  /// 底部内边距的缩写。
  Widget pb(double value) => padBottom(value);

  /// 左侧内边距的缩写。
  Widget pl(double value) => padLeft(value);

  /// 右侧内边距的缩写。
  Widget pr(double value) => padRight(value);

  /// 水平方向内边距的缩写。
  Widget px(double value) => padHorizontal(value);

  /// 垂直方向内边距的缩写。
  Widget py(double value) => padVertical(value);
}

/// [String] 的快捷文本样式扩展。
extension HlText on String {
  /// 以当前字符串为内容创建 [Text]。
  ///
  /// [size] 为字号，[color] / [weight] 控制颜色与字重，
  /// [align] / [maxLines] / [overflow] 控制排版。
  Text text(
    double size, {
    Color? color,
    FontWeight? weight,
    TextAlign? align,
    int? maxLines,
    TextOverflow? overflow,
  }) => Text(
    this,
    textAlign: align,
    maxLines: maxLines,
    overflow: overflow,
    style: TextStyle(fontSize: size, color: color, fontWeight: weight),
  );

  /// 13 号常规文本。
  Text text13({TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) =>
      text(13, align: textAlign, maxLines: maxLines, overflow: overflow);

  /// 13 号灰色文本。
  Text text13Grey({
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => text(
    13,
    color: HlColor.textGrey,
    align: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// 14 号灰色文本。
  Text text14Grey({
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => text(
    14,
    color: HlColor.textGrey,
    align: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// 14 号 500 字重文本。
  Text text14w500({
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => text(
    14,
    weight: FontWeight.w500,
    align: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );

  /// 16 号 500 字重文本。
  Text text16w500({
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) => text(
    16,
    weight: FontWeight.w500,
    align: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}
