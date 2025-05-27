import 'package:flutter/services.dart';
import '../models/message_section.dart';

class MessageService {
  Future<List<MessageSection>> loadSections(String langCode) async {
    final assetPath = 'assets/text/$langCode.txt';
    final rawText = await rootBundle.loadString(assetPath);
    return _parseSections(rawText);
  }

  List<MessageSection> _parseSections(String text) {
    final lines = text.split('\n');
    final sections = <MessageSection>[];
    String? currentTitle;
    StringBuffer currentContent = StringBuffer();

    for (var line in lines) {
      if (line.trim().startsWith('##')) {
        if (currentTitle != null) {
          sections.add(MessageSection(currentTitle, currentContent.toString().trim()));
          currentContent.clear();
        }
        currentTitle = line.replaceFirst('##', '').trim();
      } else {
        currentContent.writeln(line);
      }
    }

    if (currentTitle != null) {
      sections.add(MessageSection(currentTitle, currentContent.toString().trim()));
    }

    return sections;
  }
}
