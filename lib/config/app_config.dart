class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://fastapi-backend-226835992406.us-central1.run.app',
  );
}
