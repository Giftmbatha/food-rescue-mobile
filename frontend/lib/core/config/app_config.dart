class AppConfig {
  const AppConfig._();

  // Android emulator -> host machine.
  // Change this for a physical device or deployed backend.
  static const String baseUrl = 'http://192.168.8.253:8080/api/v1';

  static const Duration connectTimeout =
      Duration(seconds: 15);

  static const Duration receiveTimeout =
      Duration(seconds: 30);
}
