// Centralized runtime configuration for API and Socket endpoints
// Use --dart-define to override in builds:
// flutter run --dart-define=API_BASE_URL=https://api.example.com/api --dart-define=SOCKET_BASE_URL=https://api.example.com

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.1.19:5000/api',
);

const String socketBaseUrl = String.fromEnvironment(
  'SOCKET_BASE_URL',
  defaultValue: 'http://192.168.1.19:5000',
);


