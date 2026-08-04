class AppConstants {
  AppConstants._();

  static const int sessionDurationMinutes = 50;
  static const String consentVersion =
      '2026-01'; // Increment when consent text changes

  static const String kaanPeteRoiNumber =
      '01779554391'; // No dashes for tel: URI
  static const String kaanPeteRoiDisplay = '01779-554391'; // Display format
  static const String emergencyNumber = '999';

  static const int maxMessageLength = 2000;
  static const int maxProblemNoteLength = 500;
  static const int maxMoodNoteLength = 280;
  static const int moodHistoryDays = 30;
  static const int maxBioLength = 600;

  static const int defaultSessionFeeDiu = 0;
  static const int defaultSessionFeeExternal =
      1500; // BDT - override per psychologist
}
