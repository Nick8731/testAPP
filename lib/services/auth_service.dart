import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AppUser {
  final int id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['userId'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

class AuthService {
  AuthService._({ApiService? api, FlutterSecureStorage? storage})
    : _api = api ?? ApiService(),
      _storage = storage ?? const FlutterSecureStorage() {
    ApiService.onUnauthorized = invalidateToken;
  }
  @visibleForTesting
  factory AuthService.forTesting({
    required ApiService api,
    required FlutterSecureStorage storage,
  }) => AuthService._(api: api, storage: storage);

  static final AuthService instance = AuthService._();
  static const _tokenKey = 'smashcoach_access_token';

  final ApiService _api;
  final FlutterSecureStorage _storage;
  final ValueNotifier<AppUser?> currentUserChanges = ValueNotifier<AppUser?>(
    null,
  );
  final ValueNotifier<String?> sessionMessage = ValueNotifier(null);
  Future<void>? _restoring;
  int _generation = 0;
  int? _loggingInGeneration;
  Future<void> _storageQueue = Future.value();

  Future<void> _persist(int generation, String? value) {
    final operation = _storageQueue.catchError((Object _) {}).then((_) async {
      if (generation != _generation) return;
      if (value == null) {
        await _storage.delete(key: _tokenKey);
      } else {
        await _storage.write(key: _tokenKey, value: value);
      }
    });
    _storageQueue = operation;
    return operation;
  }

  AppUser? get currentUser => currentUserChanges.value;

  Future<String?> get token async {
    await _storageQueue;
    return _storage.read(key: _tokenKey);
  }

  Future<bool> get isLoggedIn async => (await token)?.isNotEmpty == true;

  Future<void> restoreSession() =>
      _restoring ??= _restore().whenComplete(() => _restoring = null);

  Future<void> _restore() async {
    if (currentUser != null) return;
    final generation = _generation;
    sessionMessage.value = '正在確認登入狀態…教學內容可先使用。';
    try {
      final accessToken = await token;
      if (generation != _generation) return;
      if (accessToken == null || accessToken.isEmpty) {
        sessionMessage.value = null;
        return;
      }
      final user = await _fetchCurrentUser(accessToken);
      if (generation != _generation) return;
      currentUserChanges.value = user;
      sessionMessage.value = null;
    } catch (_) {
      if (generation == _generation) {
        sessionMessage.value = '暫時無法確認會員資料，教學仍可使用；連線恢復後按登入／註冊重試。';
      }
    }
  }

  Future<void> invalidateToken(String rejectedToken) async {
    if (_loggingInGeneration != null) return;
    final generation = _generation;
    if (await token != rejectedToken ||
        generation != _generation ||
        _loggingInGeneration != null) {
      return;
    }
    final next = ++_generation;
    final persistence = _persist(next, null);
    currentUserChanges.value = null;
    sessionMessage.value = '登入已過期，請重新登入；已儲存紀錄仍保留在原帳號。';
    await persistence;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _api.postJson('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }

  Future<void> login({required String email, required String password}) async {
    final generation = ++_generation;
    _loggingInGeneration = generation;
    try {
      final json = await _api.postJson('/auth/login', {
        'email': email.trim(),
        'password': password,
      });
      final accessToken = json['accessToken'] as String;
      final user = await _fetchCurrentUser(accessToken);
      if (generation != _generation) throw const ApiException('登入已取消，請重新操作');
      await _persist(generation, accessToken);
      if (generation != _generation) throw const ApiException('登入已取消，請重新操作');
      currentUserChanges.value = user;
      sessionMessage.value = null;
    } finally {
      if (_loggingInGeneration == generation) _loggingInGeneration = null;
    }
  }

  Future<AppUser> getCurrentUser() async {
    if (currentUser case final user?) return user;
    final generation = _generation;
    final accessToken = await requireToken();
    if (generation != _generation) {
      throw const ApiException('請重新登入', statusCode: 401);
    }
    final user = await _fetchCurrentUser(accessToken);
    if (generation != _generation) {
      throw const ApiException('請重新登入', statusCode: 401);
    }
    currentUserChanges.value = user;
    return user;
  }

  Future<AppUser> _fetchCurrentUser(String accessToken) async =>
      AppUser.fromJson(await _api.getJson('/users/me', token: accessToken));

  Future<String> requireToken() async {
    final generation = _generation;
    final accessToken = await token;
    if (generation != _generation ||
        accessToken == null ||
        accessToken.isEmpty) {
      throw const ApiException('請先登入', statusCode: 401);
    }
    return accessToken;
  }

  Future<void> logout() async {
    final generation = ++_generation;
    final persistence = _persist(generation, null);
    currentUserChanges.value = null;
    sessionMessage.value = null;
    await persistence;
  }
}
