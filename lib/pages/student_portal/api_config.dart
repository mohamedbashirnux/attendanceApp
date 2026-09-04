// The student portal shares the same backend as the teacher portal,
// so it uses the same base URL configuration. Re-export the teacher
// version under this path so existing imports keep working.
export '../teacher_portal/api_config.dart' show resolveBaseUrl;
