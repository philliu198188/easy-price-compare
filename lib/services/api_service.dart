import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// API 错误
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 网络请求超时异常
class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([String message = '请求超时，请检查网络'])
      : super(message);
}

/// 网络错误异常
class ApiNetworkException extends ApiException {
  const ApiNetworkException([String message = '网络连接失败，请检查网络'])
      : super(message);
}

/// API 服务基类
///
/// 使用方式：
/// ```dart
/// final api = ApiService(baseUrl: 'https://api.example.com');
/// final result = await api.get('/products');
/// ```
class ApiService {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final http.Client _client;

  ApiService({
    this.baseUrl = '',
    Duration? timeout,
    Map<String, String>? defaultHeaders,
    http.Client? client,
  })  : timeout = timeout ?? const Duration(seconds: 10),
        defaultHeaders = defaultHeaders ?? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        _client = client ?? http.Client();

  /// 构建完整 URL
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// 合并请求头
  Map<String, String> _mergeHeaders([Map<String, String>? extra]) {
    if (extra == null) return Map.of(defaultHeaders);
    return {...defaultHeaders, ...extra};
  }

  // ==================== GET ====================

  /// GET 请求，返回解析后的 JSON
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw ApiNetworkException();
    }
  }

  /// GET 请求，返回原始响应字符串
  Future<String> getRaw(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      }
      throw _handleResponse(response);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw ApiNetworkException();
    }
  }

  // ==================== POST ====================

  /// POST 请求，body 自动 JSON 编码
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .post(
            uri,
            headers: _mergeHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw ApiNetworkException();
    }
  }

  // ==================== PUT ====================

  /// PUT 请求
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .put(
            uri,
            headers: _mergeHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw ApiNetworkException();
    }
  }

  // ==================== DELETE ====================

  /// DELETE 请求
  Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await _client
          .delete(uri, headers: _mergeHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiTimeoutException();
    } on SocketException {
      throw ApiNetworkException();
    }
  }

  // ==================== 内部方法 ====================

  /// 处理 HTTP 响应
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? body['error'] ?? '请求失败';
    } catch (_) {
      message = '请求失败 ($statusCode)';
    }
    throw ApiException(message, statusCode: statusCode);
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}