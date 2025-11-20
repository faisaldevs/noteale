import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  String version = '';
  String buildNumber = '';

  Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      buildNumber = info.buildNumber;
    } catch (e) {
      version = 'unknown';
      buildNumber = '0';
    }
  }

  String get fullVersion => '$version+$buildNumber';
}
