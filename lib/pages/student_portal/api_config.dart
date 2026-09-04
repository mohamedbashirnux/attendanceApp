// The student portal shares the same backend as the teacher portal,
// so it uses the same base URL configuration. This file re-exports
// [resolveBaseUrl] from the teacher config so a single edit at
// `lib/pages/teacher_portal/api_config.dart` (kOverrideBaseUrl)
// covers both portals.
export '../teacher_portal/api_config.dart' show resolveBaseUrl;
