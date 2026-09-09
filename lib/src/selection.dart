import 'package:flutter/foundation.dart';

/// 可被 [HlSelectionController] 管理的选择项抽象。
abstract interface class HlSelectionItem {
  /// 选择项的唯一标识。
  String get id;
}

/// 单选控制器，基于 [ValueNotifier] 管理当前选中项。
class HlSelectionController<T extends HlSelectionItem> {
  /// 创建一个单选控制器。
  ///
  /// [initialValue] 为初始选中项，可为 `null`。
  HlSelectionController({T? initialValue})
    : value = ValueNotifier<T?>(initialValue);

  /// 当前选中项的监听器，供 UI 订阅。
  final ValueNotifier<T?> value;

  /// 按 [id] 在 [items] 中查找并选中对应项。
  ///
  /// [id] 为 `null` 或未找到时清空选中项。
  void selectById(Iterable<T> items, String? id) {
    if (id == null) {
      clear();
      return;
    }
    for (final item in items) {
      if (item.id == id) {
        value.value = item;
        return;
      }
    }
    clear();
  }

  /// 清空当前选中项。
  void clear() => value.value = null;

  /// 释放内部 [ValueNotifier]。
  void dispose() => value.dispose();
}
