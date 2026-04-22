import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  /// Fetch messages
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final response = await supabase.from('messages').select();
    return response;
  }

  /// Fetch sections
  Future<List<Map<String, dynamic>>> fetchSections() async {
    final response = await supabase
        .from('sections')
        .select()
        .order('sort_order');
    return response;
  }

  /// Fetch translations for a specific message
  Future<List<Map<String, dynamic>>> fetchTranslations(int messageId) async {
    final response = await supabase
        .from('translations')
        .select()
        .eq('message_id', messageId);
    return response;
  }

  /// Optionally: Upload audio (in admin/editor use case)
  Future<void> uploadAudioFile(String filePath, String storagePath) async {
    final file = File(filePath);
    await supabase.storage.from('audio').upload(storagePath, file);
  }

  /// Download audio URL
  String getPublicAudioUrl(String path) {
    return supabase.storage.from('audio').getPublicUrl(path);
  }
}
