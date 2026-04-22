import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alghaya_men_alkhalg/features/reader/providers/bookmarks_provider.dart';

void main() {
  test(
    'BookmarksNotifier accurately exposes total count across all messages',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(bookmarksProvider.notifier);

      // Initial count is 0
      expect(
        container.read(bookmarksProvider).values.expand((b) => b).length,
        0,
      );

      // Add a bookmark
      await notifier.add(
        Bookmark(
          messageId: 1,
          chapterIndex: 0,
          paragraphIndex: 0,
          excerpt: 'Test',
          createdAt: DateTime.now(),
        ),
      );

      // Count is 1
      expect(
        container.read(bookmarksProvider).values.expand((b) => b).length,
        1,
      );

      // Add another bookmark for a different message
      await notifier.add(
        Bookmark(
          messageId: 2,
          chapterIndex: 1,
          paragraphIndex: 2,
          excerpt: 'Test 2',
          createdAt: DateTime.now(),
        ),
      );

      // Count is 2
      expect(
        container.read(bookmarksProvider).values.expand((b) => b).length,
        2,
      );
    },
  );
}
