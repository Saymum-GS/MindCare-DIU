class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String screenings = 'screenings';
  static const String chatSessions = 'chatSessions';
  static const String messages = 'messages'; // Subcollection name
  static const String bookings = 'bookings';
  static const String psychologistSlots =
      'psychologistSlots'; // Exact name - never vary
  static const String moodEntries = 'moodEntries';
  static const String incidents = 'incidents';
  static const String auditLogs = 'auditLogs';
  static const String content = 'content';

  static String chatMessages(String sessionId) =>
      'chatSessions/$sessionId/messages';
}
