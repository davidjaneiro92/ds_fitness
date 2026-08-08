import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens/color_tokens.dart';
import 'tokens/spacing_tokens.dart';
import 'tokens/typography_tokens.dart';

/// Tema unico do app — dark by design (planejamento §1).
abstract class AppTheme {
  static const SystemUiOverlayStyle systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: ColorTokens.bgPrimary,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ColorTokens.bgPrimary,
        canvasColor: ColorTokens.bgPrimary,
        splashFactory: InkRipple.splashFactory,
        colorScheme: const ColorScheme.dark(
          primary: ColorTokens.accent,
          onPrimary: ColorTokens.textOnAccent,
          secondary: ColorTokens.accentDark,
          onSecondary: ColorTokens.textPrimary,
          surface: ColorTokens.bgSurface,
          onSurface: ColorTokens.textPrimary,
          error: ColorTokens.danger,
          onError: ColorTokens.textPrimary,
          outline: ColorTokens.divider,
        ),
        textTheme: TypographyTokens.textTheme,
        dividerTheme: const DividerThemeData(
          color: ColorTokens.divider,
          thickness: 1,
          space: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: ColorTokens.bgPrimary,
          foregroundColor: ColorTokens.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: systemOverlay,
          titleTextStyle: TypographyTokens.screenTitle,
        ),
        iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: ColorTokens.accent,
          linearTrackColor: ColorTokens.bgSurfaceAlt,
          circularTrackColor: ColorTokens.bgSurfaceAlt,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: ColorTokens.bgSurface,
          modalBackgroundColor: ColorTokens.bgSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.lg),
            ),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: ColorTokens.bgSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusCard),
          ),
          titleTextStyle: TypographyTokens.cardTitle,
          contentTextStyle: TypographyTokens.bodyMuted,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: ColorTokens.bgSurfaceAlt,
          contentTextStyle: TypographyTokens.bodyStrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorTokens.bgSurfaceAlt,
          isDense: true,
          hintStyle: TypographyTokens.bodyMuted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: ColorTokens.accent),
          errorBorder: _inputBorder(color: ColorTokens.danger),
          focusedErrorBorder: _inputBorder(color: ColorTokens.danger),
          errorStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorTokens.danger,
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: ColorTokens.accent,
          inactiveTrackColor: ColorTokens.bgSurfaceAlt,
          thumbColor: ColorTokens.accent,
        ),
      );

  static OutlineInputBorder _inputBorder({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusButton),
      borderSide: BorderSide(
        color: color,
        width: color == Colors.transparent ? 0 : 1.4,
      ),
    );
  }
}
