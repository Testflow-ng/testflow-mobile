class ApiConfig {
  ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://testflow-nacq.onrender.com',
  );
}
