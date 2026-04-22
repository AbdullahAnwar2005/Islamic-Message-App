import '../app_database.dart';

class FullMessageModel {
  final int id;
  final String slug;
  final String title;
  final bool isPublished;
  final String languageCode;
  final String content;
  final String? audioUrl;
  final String audioPath;

  final String? titleAr;
  final String? titleEn;

  const FullMessageModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.isPublished,
    required this.languageCode,
    required this.content,
    required this.audioUrl,
    required this.audioPath,
    this.titleAr,
    this.titleEn,
  });

  factory FullMessageModel.fromDb({
    required Message message,
    required Translation translation,
  }) {
    return FullMessageModel(
      id: message.id,
      slug: message.slug,
      title: message.title,
      isPublished: message.isPublished,
      languageCode: translation.languageCode,
      content: translation.content,
      audioUrl: translation.audioUrl,
      audioPath: translation.audioPath,
      titleAr: message.titleAr,
      titleEn: message.titleEn,
    );
  }

  /// Helper to get title based on App Language (not Content Language)
  String localizedTitle(String appLangCode) {
    // If exact match
    if (appLangCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    if (appLangCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    // Fallback
    return title;
  }
}
