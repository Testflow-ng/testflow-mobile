import 'package:flutter/material.dart';

/// TestFlow official color system — extracted from the website's global.css
/// Primary: #2563eb (vivid blue), Secondary: #7c3aed (purple)
class AppColors {
  AppColors._();

  // ─── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color primaryActive = Color(0xFF1E40AF);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryHover = Color(0xFF6D28D9);
  static const Color secondaryActive = Color(0xFF5B21B6);
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  // ─── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFF0F172A);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerForeground = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoForeground = Color(0xFFFFFFFF);
  static const Color neutral = Color(0xFF64748B);
  static const Color neutralForeground = Color(0xFFFFFFFF);

  // ─── Light Surface / Text ──────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceStrongLight = Color(0xFFEDF1F5);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderStrongLight = Color(0xFFCBD5E1);
  static const Color textPrimaryLight = Color(0xFF0F172A);  // gray-900
  static const Color textSecondaryLight = Color(0xFF334155);
  static const Color textMutedLight = Color(0xFF64748B);

  // ─── Dark Surface / Text ───────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A0F1E);
  static const Color surfaceDark = Color(0xFF141B2E);
  static const Color surfaceStrongDark = Color(0xFF1C2440);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderStrongDark = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // ─── Dark Primary (lighter for dark mode) ─────────────────────────────────
  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color primaryForegroundDark = Color(0xFF0F172A);
  static const Color secondaryDark = Color(0xFFA78BFA);

  // ─── Gray Scale ────────────────────────────────────────────────────────────
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // ─── Gradient presets ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
  );
}
