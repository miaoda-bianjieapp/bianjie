class ApiConfig {
  const ApiConfig._();

  static const bool useRemoteApi = bool.fromEnvironment(
    'BIANJIE_USE_REMOTE_API',
    defaultValue: false,
  );

  static const String baseUrl = String.fromEnvironment(
    'BIANJIE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String apiPrefix = '/api/v1';
}
