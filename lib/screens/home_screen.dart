import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'message_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.RTL;
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
          isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '﷽',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'welcome'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MessageScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: Text('read_text'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
