import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ----- MINDCARE PREMIUM PALETTE -----
  
  // Base Neutral/Slate Scale (replaces stark greys)
  static const Color white = Color(0xFFFFFFFF);
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

  // Core Brand Blue Scale (Trust, Calm, Ocean)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // Success / Sage Green Scale (Growth, Positivity)
  static const Color sage50 = Color(0xFFECFDF5);
  static const Color sage100 = Color(0xFFD1FAE5);
  static const Color sage500 = Color(0xFF10B981);
  static const Color sage600 = Color(0xFF059669);

  // Warning / Amber Scale (Warmth, Attention)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);

  // Purple / Clinical Scale (Professionalism, Wisdom)
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple200 = Color(0xFFE9D5FF);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple900 = Color(0xFF581C87);

  // Danger / Red Scale (Alerts, Urgency)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red900 = Color(0xFF7F1D1D);

  // ----- THEME TOKENS -----
  
  // Dark Mode Core
  static const Color darkBg = gray900;
  static const Color darkSurface = gray800;
  static const Color darkSurface2 = gray700;
  static const Color darkSurface3 = gray600;
  
  // Borders
  static const Color darkBorder = gray700;
  static const Color darkBorderSoft = gray800;

  // Text
  static const Color darkText = gray50;
  static const Color darkTextSub = gray400;
  static const Color darkTextTert = gray500;

  // Legacy Semantic Aliases (to ensure no errors)
  static const Color systemBlueLight = blue500;
  static const Color systemBlueDark = blue400;
  static const Color systemRedLight = red500;
  static const Color systemRedDark = red400;
  static const Color systemGreenLight = sage500;
  static const Color systemGreenDark = sage400; // fallback if needed
  static const Color systemOrangeLight = amber500;
  static const Color systemOrangeDark = amber400; // fallback if needed

  // Aliases for missing colors to prevent errors
  static const Color sage400 = Color(0xFF34D399);
  static const Color amber400 = Color(0xFFFBBF24);

  // Screening Colors (Semantic)
  static const Color riskGreenFg = sage600;
  static const Color riskGreenFgDark = sage400;
  static const Color riskGreenBg = sage50;
  static const Color riskGreenBgDark = Color(0xFF064E3B);
  
  static const Color riskYellowFg = amber600;
  static const Color riskYellowFgDark = amber400;
  static const Color riskYellowBg = amber50;
  static const Color riskYellowBgDark = Color(0xFF78350F);

  static const Color riskRedFg = red700;
  static const Color riskRedFgDark = red400;
  static const Color riskRedBg = red50;
  static const Color riskRedBgDark = red900;

  // Crisis Mode Colors
  static const Color crisisBg = gray900;
  static const Color crisisSurface = gray800;
  static const Color crisisAccent = red600;
  static const Color red600 = Color(0xFFDC2626);
}
