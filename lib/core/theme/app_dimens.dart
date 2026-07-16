/// Design tokens extracted from TestFlow website CSS:
/// Radius: sm=6px, md=12px, lg=24px, full=9999px
/// Spacing follows an 8-pt grid system
class AppDimens {
  AppDimens._();

  // ─── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusNone = 0;
  static const double radiusSm = 6;    // 0.375rem
  static const double radiusMd = 12;   // 0.75rem
  static const double radiusLg = 24;   // 1.5rem
  static const double radiusFull = 9999;

  // ─── Spacing scale (8-pt grid) ────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 40;
  static const double space8 = 48;
  static const double space9 = 64;

  // ─── Elevation / Shadow offsets ───────────────────────────────────────────
  static const double shadowBlurXs = 2;
  static const double shadowBlurSm = 3;
  static const double shadowBlurMd = 30;
  static const double shadowBlurLg = 60;
  static const double shadowBlurXl = 80;

  // ─── Icon sizes ───────────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconXxl = 48;

  // ─── Logo sizes ────────────────────────────────────────────────────────────
  static const double logoSm = 32;
  static const double logoMd = 48;
  static const double logoLg = 80;
  static const double logoXl = 120;

  // ─── Button heights ────────────────────────────────────────────────────────
  static const double buttonSm = 36;
  static const double buttonMd = 44;
  static const double buttonLg = 56;  // matches website h-14 (3.5rem)

  // ─── Input height ──────────────────────────────────────────────────────────
  static const double inputHeight = 52;

  // ─── Screen padding ────────────────────────────────────────────────────────
  static const double screenPadding = 24;
  static const double screenPaddingSm = 16;
}
