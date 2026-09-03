/// Resolves the API base URL.
///
/// Defaults to the local Next.js dev server (`http://localhost:3000`).
/// On a physical Android device, override with `--dart-define=API_BASE_URL=...`
/// at build time so the device can reach the host machine.
String resolveBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;
  return 'http://localhost:3000';
}
