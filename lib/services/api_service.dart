import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static Future<void> Function(String token)? onUnauthorized;
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  final http.Client _client;
  static const _requestTimeout = Duration(seconds: 15);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    return _decode(
      await _send(
        _client.get(_uri(path), headers: _headers(token)),
        token: token,
      ),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    return _decode(
      await _send(
        _client.post(
          _uri(path),
          headers: _headers(token),
          body: jsonEncode(body),
        ),
        token: token,
      ),
    );
  }

  Future<void> delete(String path, {required String token}) async {
    final response = await _send(
      _client.delete(_uri(path), headers: _headers(token)),
      token: token,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwResponse(response);
    }
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<http.Response> _send(
    Future<http.Response> request, {
    String? token,
  }) async {
    try {
      final response = await request.timeout(_requestTimeout);
      if (response.statusCode == 401 && token != null) {
        await onUnauthorized?.call(token);
      }
      return response;
    } on TimeoutException {
      throw const ApiException('伺服器回應逾時，請確認後台已啟動後再試一次');
    } on SocketException {
      throw const ApiException('無法連接伺服器，請確認網路與後台服務是否正常');
    } on http.ClientException {
      throw const ApiException('無法連接伺服器，請確認 API 位址與後台服務');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwResponse(response);
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } on FormatException {
      throw const ApiException('伺服器回傳格式不正確，請稍後再試');
    }
  }

  Never _throwResponse(http.Response response) {
    var message = switch (response.statusCode) {
      400 => '送出的資料不正確，請檢查後再試',
      401 => '登入狀態已失效，請重新登入',
      403 => '你沒有權限執行這項操作',
      404 => '找不到指定的資料',
      409 => '這筆資料已經存在',
      422 => '輸入內容格式不正確',
      >= 500 => '伺服器暫時發生問題，請稍後再試',
      _ => '操作失敗（${response.statusCode}）',
    };
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) message = detail;
      }
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }
}
