import 'dart:convert';
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
///
/// 网络 SVG（[HlIconType.networkSvg]）通过内部下载后用
/// `SvgPicture.string` 渲染，因此支持 [errorWidget] 兜底。
class HlIcon extends StatefulWidget {
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

  @override
  State<HlIcon> createState() => _HlIconState();
}

class _HlIconState extends State<HlIcon> {
  Future<String>? _svgFuture;

  @override
  void initState() {
    super.initState();
    if (widget.type == HlIconType.networkSvg && widget.source.isNotEmpty) {
      _svgFuture = _downloadSvg(widget.source);
    }
  }

  @override
  void didUpdateWidget(covariant HlIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.type != widget.type) {
      if (widget.type == HlIconType.networkSvg &&
          widget.source.isNotEmpty) {
        _svgFuture = _downloadSvg(widget.source);
      } else {
        _svgFuture = null;
      }
    }
  }

  /// 加载中/空源的兜底内容。
  Widget get _fallback =>
      widget.placeholder ??
      SizedBox(width: widget.width ?? 16, height: widget.height ?? 16);

  /// 加载失败的兜底内容。
  Widget get _error => widget.errorWidget ?? _fallback;

  /// 下载网络 SVG 内容，失败时抛出异常由 FutureBuilder 捕获。
  ///
  /// 连接超时与整体超时均为 10 秒，避免网络异常时无限等待。
  Future<String> _downloadSvg(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return await response.transform(utf8.decoder).join().timeout(
        const Duration(seconds: 10),
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.source.isEmpty ? _fallback : _buildImage();
    if (widget.onTap == null) return child;
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: widget.onTap, child: child),
      ),
    );
  }

  /// 按 [type] 构建对应的图片/SVG 组件。
  Widget _buildImage() {
    final colorFilter = widget.color == null
        ? null
        : ColorFilter.mode(widget.color!, BlendMode.srcIn);
    switch (widget.type) {
      case HlIconType.assetSvg:
        return SvgPicture.asset(
          widget.source,
          package: widget.package,
          width: widget.width,
          height: widget.height,
          colorFilter: colorFilter,
          placeholderBuilder: (_) => _fallback,
        );
      case HlIconType.networkSvg:
        return FutureBuilder<String>(
          future: _svgFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _fallback;
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _error;
            }
            return SvgPicture.string(
              snapshot.data!,
              width: widget.width,
              height: widget.height,
              colorFilter: colorFilter,
            );
          },
        );
      case HlIconType.fileSvg:
        return SvgPicture.file(
          File(widget.source),
          width: widget.width,
          height: widget.height,
          colorFilter: colorFilter,
          placeholderBuilder: (_) => _fallback,
        );
      case HlIconType.assetImage:
        return Image.asset(
          widget.source,
          package: widget.package,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          errorBuilder: (_, _, _) => _error,
        );
      case HlIconType.networkImage:
        return Image.network(
          widget.source,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _fallback,
          errorBuilder: (_, _, _) => _error,
        );
      case HlIconType.fileImage:
        return Image.file(
          File(widget.source),
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          errorBuilder: (_, _, _) => _error,
        );
    }
  }
}
