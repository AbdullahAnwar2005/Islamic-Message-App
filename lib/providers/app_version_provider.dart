// lib/providers/app_version_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provides the app version string from package_info_plus
/// This is the single source of truth for version display
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Provides the full version+build string (e.g., "1.0.0+1")
final appVersionFullProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
});
