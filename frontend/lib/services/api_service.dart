import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/token_storage.dart';

class ApiService {
  ApiService({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokens = tokenStorage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _tokens;

  Future<String?> get accessToken => _tokens.accessToken;

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'GET',
      endpoint,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return _request(
      'POST',
      endpoint,
      body: body,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    return _request(
      'PUT',
      endpoint,
      body: body,
    );
  }

  Future<dynamic> delete(
    String endpoint,
  ) {
    return _request(
      'DELETE',
      endpoint,
    );
  }

  Future<dynamic> uploadFile(
    String endpoint,
    String filePath, {
    String? mimeType,
    Map<String, String>? extraFields,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}$endpoint',
    );

    final request =
        http.MultipartRequest('POST', uri);

    final token = await _tokens.accessToken;

    if (token != null) {
      request.headers['Authorization'] =
          'Bearer $token';
    }

    final detectedMime =
        mimeType ?? _mimeTypeFromPath(filePath);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType:
            MediaType.parse(detectedMime),
        filename: File(filePath).uri.pathSegments.last,
      ),
    );

    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    final streamed = await _client
        .send(request)
        .timeout(AppConfig.receiveTimeout);

    final response =
        await http.Response.fromStream(streamed);

    return _handleResponse(response);
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}$endpoint',
    ).replace(
      queryParameters: queryParameters,
    );

    final token = await _tokens.accessToken;

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] =
          'Bearer $token';
    }

    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(
                AppConfig.receiveTimeout,
              );
          break;

        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body == null
                    ? null
                    : jsonEncode(body),
              )
              .timeout(
                AppConfig.receiveTimeout,
              );
          break;

        case 'PUT':
          response = await _client
              .put(
                uri,
                headers: headers,
                body: body == null
                    ? null
                    : jsonEncode(body),
              )
              .timeout(
                AppConfig.receiveTimeout,
              );
          break;

        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(
                AppConfig.receiveTimeout,
              );
          break;

        default:
          throw ApiException(
            'Unsupported HTTP method: $method',
          );
      }
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond.',
      );
    } on SocketException {
      throw const ApiException(
        'Unable to connect to the server.',
      );
    }

    return _handleResponse(response);
  }

  dynamic _handleResponse(
    http.Response response,
  ) {
    dynamic decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = response.body;
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    final message = _extractErrorMessage(decoded);

    throw ApiException(
      message,
      statusCode: response.statusCode,
      details: decoded,
    );
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['message'],
        data['error'],
        data['detail'],
      ];

      for (final value in candidates) {
        if (value != null &&
            value.toString().trim().isNotEmpty) {
          return value.toString();
        }

        final nested = data['data'];

        if (nested is Map<String, dynamic>) {
          final nestedMessage =
              nested['message'] ??
                  nested['error'];

          if (nestedMessage != null) {
            return nestedMessage.toString();
          }
        }
      }
    }

    return 'Request failed.';
  }

  String _mimeTypeFromPath(String path) {
    switch (path.split('.').last.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) {
    return _tokens.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clearTokens() {
    return _tokens.clear();
  }

  Future<void> dispose() async {
    _client.close();
  }
}
