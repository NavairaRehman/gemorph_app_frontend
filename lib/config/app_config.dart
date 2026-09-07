class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
