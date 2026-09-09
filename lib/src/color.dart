import 'package:flutter/material.dart';

/// 全局业务配色常量，提供一套可整体覆盖的主题色。
class HlColor {
  HlColor._();

  static Color mainDarkColor = const Color(0xFF111827);
  static Color mainLightColor = const Color(0xFF111827);
  static Color bgWhite = const Color(0xFFFFFFFF);
  static Color bgBlack = const Color(0xFF1F1F1F);
  static Color bgGrey = const Color(0xFFF7F9FC);
  static Color bgGreyLight = const Color(0xFFFAFAFA);
  static Color bgGreyDark = const Color(0xFFE8EDF3);
  static Color bgSuccessLight = const Color(0x14059669);
  static Color bgErrorLight = const Color(0x14FE5152);
  static Color bgWarnLight = const Color(0x14FFBF2D);
  static Color textBlack = const Color(0xFF1A2332);
  static Color textWhite = const Color(0xFFFFFFFF);
  static Color textGrey = const Color(0xFF64748B);
  static Color textGreyLight = const Color(0xFF94A3B8);
  static Color textSuccess = const Color(0xFF059669);
  static Color textError = const Color(0xFFFE5152);
  static Color textWarn = const Color(0xFFFFBF2D);
  static Color lineGrey = const Color(0xFFE8EDF3);

  /// 批量覆盖配色常量。
  ///
  /// 仅覆盖传入的非空项，未传项保持现有值；适合在应用启动时
  /// 根据品牌主题统一配置。
  ///
  /// - [mainDark] / [mainLight]: 主色（深色/浅色），对应 [mainDarkColor] /
  ///   [mainLightColor]。
  /// - [backgroundWhite] / [backgroundBlack]: 白/黑背景，对应 [bgWhite] /
  ///   [bgBlack]。
  /// - [background]: 常规背景，对应 [bgGrey]。
  /// - [backgroundLight]: 浅色背景，对应 [bgGreyLight]。
  /// - [backgroundDisabled]: 禁用背景，对应 [bgGreyDark]。
  /// - [successBackground] / [errorBackground] / [warningBackground]:
  ///   成功/错误/警告的浅色背景，对应 [bgSuccessLight] / [bgErrorLight] /
  ///   [bgWarnLight]。
  /// - [primaryText]: 主文字色，对应 [textBlack]。
  /// - [inverseText]: 反色文字（白），对应 [textWhite]。
  /// - [secondaryText] / [tertiaryText]: 次级/三级文字色，对应 [textGrey] /
  ///   [textGreyLight]。
  /// - [successText] / [errorText] / [warningText]: 成功/错误/警告文字色，
  ///   对应 [textSuccess] / [textError] / [textWarn]。
  /// - [divider]: 分隔线色，对应 [lineGrey]。
  static void configure({
    Color? mainDark,
    Color? mainLight,
    Color? backgroundWhite,
    Color? backgroundBlack,
    Color? background,
    Color? backgroundLight,
    Color? backgroundDisabled,
    Color? successBackground,
    Color? errorBackground,
    Color? warningBackground,
    Color? primaryText,
    Color? inverseText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? successText,
    Color? errorText,
    Color? warningText,
    Color? divider,
  }) {
    mainDarkColor = mainDark ?? mainDarkColor;
    mainLightColor = mainLight ?? mainLightColor;
    bgWhite = backgroundWhite ?? bgWhite;
    bgBlack = backgroundBlack ?? bgBlack;
    bgGrey = background ?? bgGrey;
    bgGreyLight = backgroundLight ?? bgGreyLight;
    bgGreyDark = backgroundDisabled ?? bgGreyDark;
    bgSuccessLight = successBackground ?? bgSuccessLight;
    bgErrorLight = errorBackground ?? bgErrorLight;
    bgWarnLight = warningBackground ?? bgWarnLight;
    textBlack = primaryText ?? textBlack;
    textWhite = inverseText ?? textWhite;
    textGrey = secondaryText ?? textGrey;
    textGreyLight = tertiaryText ?? textGreyLight;
    textSuccess = successText ?? textSuccess;
    textError = errorText ?? textError;
    textWarn = warningText ?? textWarn;
    lineGrey = divider ?? lineGrey;
  }
}
