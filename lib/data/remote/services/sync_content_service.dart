import 'package:alghaya_men_alkhalg/data/remote/services/supabase_services.dart';

import '../../local/app_database.dart';


class SyncService {
  final AppDatabase db;
  final SupabaseService remote;

  SyncService(this.db, this.remote);

  Future<void> syncMessages() async {
    final remoteMessages = await remote.fetchMessages();

    for (final msg in remoteMessages) {
      final exists = await db.messageExists(msg['id']);
      if (!exists) {
        await db.insertMessageFromRemote(msg);
        final translations = await remote.fetchTranslations(msg['id']);
        for (final tr in translations) {
          await db.insertTranslationFromRemote(tr);
        }
      }
    }

    print('✅ Sync complete');
  }
}
