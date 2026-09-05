/// Single place to swap the API base URL between dev and prod.
///
/// Notes for development:
/// - Web / Windows / macOS / Linux desktop: `http://localhost:3000` works.
/// - Android emulator: `localhost` on the emulator points to the emulator
///   itself, not the host machine. We rewrite to `10.0.2.2` automatically
///   so the emulator can reach the dev server.
/// - Real Android device: replace with your dev machine's LAN IP, e.g.
///   `http://192.168.100.4:3000`. To override the auto-detect, just set
///   [kOverrideBaseUrl] below to a non-empty value.
const String _kDefaultBaseUrl = 'http://localhost:3000';
const String kOverrideBaseUrl = 'http://192.168.100.4:3000'; // phone → laptop LAN IP

/// Resolved base URL at runtime, accounting for platform.
String resolveBaseUrl() {
  if (kOverrideBaseUrl.isNotEmpty) return kOverrideBaseUrl;
  // Android emulator special-case: route 10.0.2.2 to host loopback.
  if (_isAndroidEmulator && _kDefaultBaseUrl.contains('localhost')) {
    return _kDefaultBaseUrl.replaceFirst('localhost', '10.0.2.2');
  }
  return _kDefaultBaseUrl;
}

bool _isAndroidEmulator = false;

/// Lets [resolveBaseUrl] know we're on the Android emulator at runtime.
void configureAndroidEmulator({required bool isEmulator}) {
  _isAndroidEmulator = isEmulator;
}
