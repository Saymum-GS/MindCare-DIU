// lib/core/utils/crisis_detector.dart

class CrisisDetector {
  static const List<String> highRiskKeywords = [
    // Direct Self-Harm / Suicide
    'suicide',
    'kill myself',
    'want to die',
    'end my life',
    'better off dead',
    'end it all',
    'take my own life',
    'die',
    
    // Hopelessness / Despair
    'no reason to live',
    'not want to be here',
    'make it stop',
    'can\'t go on',
    'done with everything',
    'give up on life',
    
    // Self-Harm Behaviors
    'cut myself',
    'hurt myself',
    'harm myself',
    'burn myself',
    'punish myself',
    'slitting my wrists',
    
    // Substance / Overdose
    'take pills',
    'drink until',
    'overdose',
    'swallow a bottle',
    
    // Violence towards others (Red flag)
    'kill them',
    'hurt them',
    'make them pay',
    'shoot',
    'weapon',

    // ----- BANGLA (UNICODE) -----
    'আত্মহত্যা', // suicide
    'মরে যেতে চাই', // want to die
    'বাঁচতে চাই না', // don't want to live
    'বিষ খাব', // take poison
    'গলায় দড়ি', // hang myself
    'জীবন শেষ', // end life
    'কাউকে মারব', // kill someone
    'মেরে ফেলব', // kill
    'শান্তি চাই', // often used in desperation context
    'সব শেষ', // everything is over

    // ----- BANGLISH (ROMANIZED BANGLA) -----
    'attoghati',
    'attohotta',
    'mora jete chai',
    'more jete chai',
    'bachte chai na',
    'morte chai',
    'bish khabo',
    'bish khai',
    'golay dori',
    'jibon sesh',
    'jibon ses',
    'jibon sesh kore dibo',
    'shob sesh',
    'sob ses',
    'mere felbo',
    'mere phelbo',
    'khun korbo',
    'pills khabo',
    'pills khai',
    'ghum er osud',
    'ghum er ousud',
    'reash kete',
    'haat kete',
    'hat katbo',
  ];

  /// Checks if the message text contains any high-risk crisis keywords.
  static bool isCrisis(String text) {
    return getDetectedKeyword(text) != null;
  }

  /// Returns the first crisis keyword detected in the text, or null if none are found.
  /// Uses regex for word-boundary matching to prevent false positives (e.g., matching "diet" in "die").
  static String? getDetectedKeyword(String text) {
    if (text.isEmpty) return null;
    final lowerText = text.toLowerCase();

    for (final keyword in highRiskKeywords) {
      // Use boundary match if the keyword is a single word to avoid false positives.
      // E.g., 'die' shouldn't match 'diet'.
      if (!keyword.contains(' ')) {
        final regex = RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false);
        if (regex.hasMatch(lowerText)) {
          return keyword;
        }
      } else {
        // For phrases, a simple contains is usually sufficient and faster.
        if (lowerText.contains(keyword)) {
          return keyword;
        }
      }
    }
    return null;
  }
}
