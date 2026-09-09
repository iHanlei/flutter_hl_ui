import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 图标来源类型。
enum HlIconType {
  /// 资源目录中的 SVG 文件。
  assetSvg,

  /// 网络地址的 SVG 文件。
  networkSvg,

  /// 本地文件系统的 SVG 文件。
  fileSvg,

  /// 资源目录中的位图。
  assetImage,

  /// 网络地址的位图。
  networkImage,

  /// 本地文件系统的位图。
  fileImage,
}

/// 支持多种来源与类型的图标组件。
///
/// 可加载资源/网络/文件路径下的 SVG 或位图，支持着色、尺寸、
/// 点击回调与加载占位/错误兜底。
class HlIcon extends StatelessWidget {
  /// 创建一个图标。
  ///
  /// [source] 为资源路径或网络地址（依 [type] 而定）；
  /// [type] 为来源类型；[width] / [height] 控制尺寸（SVG 场景必填其一
  /// 否则使用 [placeholder] 尺寸）；[color] 为着色（位图不支持）；
  /// [onTap] 为点击回调；[placeholder] / [errorWidget] 为加载占位与
  /// 失败兜底；[package] 用于从指定包加载资源 SVG/位图。
  const HlIcon({
    super.key,
    required this.source,
    this.type = HlIconType.assetSvg,
    this.width,
    this.height,
    this.color,
    this.fit,
    this.onTap,
    this.placeholder,
    this.errorWidget,
    this.package,
  });

  final String source;
  final HlIconType type;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final GestureTapCallback? onTap;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? package;

  /// 加载中/空源的兜底内容。
  Widget get _fallback =>
      placeholder ?? SizedBox(width: width ?? 16, height: height ?? 16);

  /// 加载失败的兜底内容。
  Widget get _error => errorWidget ?? _fallback;

  @override
  Widget build(BuildContext context) {
    final child = source.isEmpty ? _fallback : _buildImage();
    return onTap == null ? child : GestureDetector(onTap: onTap, child: child);
  }

  /// 按 [type] 构建对应的图片/SVG 组件。
  Widget _buildImage() {
    final colorFilter = color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn);
    return switch (type) {
      HlIconType.assetSvg => SvgPicture.asset(
        source,
        package: package,
        width: width,
        height: height,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => _fallback,
      ),
      HlIconType.networkSvg => SvgPicture.network(
        source,
        width: width,
        height: height,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => _fallback,
      ),
      HlIconType.fileSvg => SvgPicture.file(
        File(source),
        width: width,
        height: height,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => _fallback,
      ),
      HlIconType.assetImage => Image.asset(
        source,
        package: package,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, _, _) => _error,
      ),
      HlIconType.networkImage => Image.network(
        source,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _fallback,
        errorBuilder: (_, _, _) => _error,
      ),
      HlIconType.fileImage => Image.file(
        File(source),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, _, _) => _error,
      ),
    };
  }
}
