import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized API client for Food Rescue backend.
/// 
/// Design decisions:
/// - Singleton pattern: one instance, one token store
/// - Automatic token refresh on 401
/// - JSON serialization handled at call site (flexible for different models)
/// - Base URL configurable per environment
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // CHANGE THIS to your machine's LAN IP
  static const String baseUrl = 'http://192.168.8.253:8080/api/v1';
  
  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  // Getters for token management
  Future<String?> get accessToken => _storage.read(key: 'accessToken');
  Future<String?> get refreshToken => _storage.read(key: 'refreshToken');

  /// Generic GET request
  Future<dynamic> get(String endpoint) async {
    final response = await _authenticatedRequest(
      () async => await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
      ),
    );
    return _decode(response);
  }

  /// Generic POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _authenticatedRequest(
      () async => await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _decode(response);
  }

  /// Generic PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _authenticatedRequest(
      () async => await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return _decode(response);
  }

  /// Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final response = await _authenticatedRequest(
      () async => await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _headers(),
      ),
    );
    return _decode(response);
  }

  /// Multipart POST for image uploads
  Future<dynamic> uploadFile(String endpoint, File file, {String fieldName = 'file', Map<String, String>? extraFields}) async {
    final token = await accessToken;
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    
    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  /// Save tokens after login/register
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  // --- Private helpers ---

  Future<Map<String, String>> _headers() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    
    // Handle errors
    final message = body?['message'] ?? 'Request failed: ${response.statusCode}';
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      body: body,
    );
  }

  /// Wrap requests with automatic token refresh on 401
  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();

    // Token expired, try refresh
    if (response.statusCode == 401) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        response = await request(); // Retry with new token
      }
    }

    return response;
  }

  Future<bool> _refreshAccessToken() async {
    final rt = await refreshToken;
    if (rt == null) return false;

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': rt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (_) {
      // Refresh failed
    }

    await clearTokens();
    return false;
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  ApiException({required this.statusCode, required this.message, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}