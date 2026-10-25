import 'package:flutter/material.dart';

/// Design tokens derived from DESIGN.md (Structure ERP System)
class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF0052CC); // Electric Blue
  static const Color primaryDark = Color(0xFF003D9B);
  static const Color primaryContainer = Color(0xFFC4D2FF);

  // Neutral Palette
  static const Color deepNavy = Color(0xFF091E42); // Primary Headers / High Contrast Text
  static const Color slateGray = Color(0xFF42526E); // Secondary Body & Label Text
  static const Color background = Color(0xFFF8F9FB); // Main App Base Layer
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Card & Input Containers
  static const Color surfaceContainer = Color(0xFFEDEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE7E8EA);

  // Borders & Dividers
  static const Color outline = Color(0xFF737685);
  static const Color outlineVariant = Color(0xFFC3C6D6);

  // Status Colors
  static const Color successEmerald = Color(0xFF36B37E); // Approved / Paid
  static const Color warningAmber = Color(0xFFFFAB00); // Pending
  static const Color errorRuby = Color(0xFFFF5630); // Rejected / Overdue / Critical
  static const Color error = Color(0xFFBA1A1A);
}
