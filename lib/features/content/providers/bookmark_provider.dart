import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookmarkProvider =
    StateNotifierProvider<BookmarkNotifier, Set<String>>((ref) {
  return BookmarkNotifier();
});

class BookmarkNotifier extends StateNotifier<Set<String>> {
  BookmarkNotifier() : super({}) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_content') ?? [];
    state = bookmarks.toSet();
  }

  Future<void> toggleBookmark(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final newBookmarks = Set<String>.from(state);

    if (newBookmarks.contains(contentId)) {
      newBookmarks.remove(contentId);
    } else {
      newBookmarks.add(contentId);
    }

    await prefs.setStringList('bookmarked_content', newBookmarks.toList());
    state = newBookmarks;
  }
}
