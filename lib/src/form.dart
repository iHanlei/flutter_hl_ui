import 'package:flutter/material.dart';

import 'theme.dart';

/// 主题化文本输入框。
class HlTextField extends StatelessWidget {
  /// 创建一个文本输入框。
  ///
  /// [controller] 为文本控制器；[label] / [hint] 为标签与占位提示；
  /// [validator] 为表单校验器；[onChanged] / [onSubmitted] 为输入与提交回调；
  /// [keyboardType] / [textInputAction] 控制键盘行为；
  /// [obscureText] 为 `true` 时以密码形式展示（强制单行）；
  /// [prefixIcon] / [suffixIcon] 为前后置图标。
  const HlTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.radii.md),
          borderSide: BorderSide(color: theme.border),
        ),
      ),
    );
  }
}

/// 下拉选择项的选项数据。
@immutable
class HlSelectOption<T> {
  /// 创建一个下拉选项。
  ///
  /// [value] 为选项值，[label] 为展示文本，[enabled] 为 `false` 时禁用。
  const HlSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// 主题化下拉选择框，支持表单校验。
class HlSelectField<T> extends StatelessWidget {
  /// 创建一个下拉选择框。
  ///
  /// [options] 为选项列表，[value] 为当前选中值，[onChanged] 为选择回调；
  /// [label] / [hint] 为标签与占位提示，[validator] 为表单校验器。
  const HlSelectField({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
  });

  final List<HlSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.hlTheme;
    final field = FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (state) => InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: state.errorText,
          filled: true,
          fillColor: theme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.radii.md),
            borderSide: BorderSide(color: theme.border),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            hint: hint == null ? null : Text(hint!),
            onChanged: enabled
                ? (next) {
                    state.didChange(next);
                    onChanged?.call(next);
                  }
                : null,
            items: options
                .map(
                  (option) => DropdownMenuItem<T>(
                    value: option.value,
                    enabled: option.enabled,
                    child: Text(option.label),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
    return enabled ? field : Opacity(opacity: 0.5, child: field);
  }
}

/// 单选框样式的表单行。
class HlCheckboxField extends StatelessWidget {
  /// 创建一个复选框表单行。
  ///
  /// [label] 为文案，[value] 为选中状态，[onChanged] 为状态变更回调。
  const HlCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: value,
    onChanged: enabled ? onChanged : null,
    title: Text(label),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
  );
}

/// 多选/单选标签组的选项数据。
@immutable
class HlChoiceOption<T> {
  /// 创建一个标签选项。
  ///
  /// [value] 为选项值，[label] 为展示文本，[enabled] 为 `false` 时禁用。
  const HlChoiceOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// 标签形式的单选/多选组。
class HlChoiceGroup<T> extends StatelessWidget {
  /// 创建一个标签选择组。
  ///
  /// [options] 为选项列表，[values] 为当前选中值集合，
  /// [onChanged] 为选中集合变更回调（仅在有可用选项且回调非空时触发）；
  /// [multiSelect] 为 `true` 时多选，否则单选。
  const HlChoiceGroup({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.multiSelect = false,
  });

  final List<HlChoiceOption<T>> options;
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.hlTheme.spacing.sm,
      runSpacing: context.hlTheme.spacing.sm,
      children: options
          .map((option) {
            final selected = values.contains(option.value);
            return FilterChip(
              label: Text(option.label),
              selected: selected,
              onSelected: !option.enabled || onChanged == null
                  ? null
                  : (next) {
                      final updated = Set<T>.of(values);
                      if (multiSelect) {
                        next
                            ? updated.add(option.value)
                            : updated.remove(option.value);
                      } else {
                        updated
                          ..clear()
                          ..add(option.value);
                      }
                      onChanged!(updated);
                    },
            );
          })
          .toList(growable: false),
    );
  }
}

/// 开关样式的表单行。
class HlSwitchField extends StatelessWidget {
  /// 创建一个开关表单行。
  ///
  /// [label] 为文案，[value] 为开关状态，[onChanged] 为状态变更回调。
  const HlSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    value: value,
    onChanged: enabled ? onChanged : null,
    title: Text(label),
    contentPadding: EdgeInsets.zero,
  );
}
