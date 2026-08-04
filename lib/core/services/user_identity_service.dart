import '../../shared/models/user_model.dart';

/// Centralised identity policy for the entire app.
///
/// Every screen that needs to display a user name, determine whether
/// the user needs profile completion, or format an identity label
/// for admin/moderation should call through this service instead of
/// inventing its own display rules.
class UserIdentityService {
  const UserIdentityService._();

  // ── Public-facing display name ──────────────────────────────────────

  /// The name shown on profile, home greeting, booking, and settings.
  /// Returns the real [displayName] for authenticated users.
  /// Returns the pseudonym for anonymous users.
  static String nameForProfile(UserModel user) {
    if (!user.isAnonymous &&
        user.displayName.isNotEmpty &&
        user.displayName != user.pseudonym) {
      return user.displayName;
    }
    return user.pseudonym;
  }

  /// The name used in peer-support chats, screening submissions,
  /// and any context where the student's real identity should be hidden.
  static String nameForChat(UserModel user) => user.pseudonym;

  // ── Admin identity ──────────────────────────────────────────────────

  /// A full identity label for admin/moderation screens.
  /// Shows displayName, email, and pseudonym together.
  static String adminIdentityLabel(UserModel user) {
    final parts = <String>[];
    if (user.displayName.isNotEmpty) parts.add(user.displayName);
    if (user.email != null && user.email!.isNotEmpty) parts.add(user.email!);
    if (user.pseudonym.isNotEmpty && user.pseudonym != user.displayName) {
      parts.add('alias: ${user.pseudonym}');
    }
    return parts.join(' · ');
  }

  // ── Profile-completion gate ─────────────────────────────────────────

  /// Returns `true` when an authenticated (non-anonymous) user still has
  /// no real display name — either because it is empty, equals the
  /// generated pseudonym, or equals the generic fallback "User".
  static bool needsProfileCompletion(UserModel user) {
    if (user.isAnonymous) return false; // anonymous users don't need it yet
    final name = user.displayName.trim();
    if (name.isEmpty) return true;
    if (name == user.pseudonym) return true;
    if (name == 'User') return true;
    return false;
  }
}
