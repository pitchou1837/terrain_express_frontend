import 'package:flutter/foundation.dart';
import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/data/repositories/auth_repository.dart';
import 'package:terrain_express/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  AuthProvider([AuthRepository? repo]) : _repo = repo ?? createAuthRepository();

  User? _user;
  bool _loading = false;
  bool _initialized = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _loading;
  bool get isInitialized => _initialized;
  String? get error => _error;

  /// Called at app start: is someone already logged in?
  Future<void> init() async {
    _user = await _repo.currentUser();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) =>
      _run(() => _repo.login(email.trim(), password));

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) =>
      _run(() => _repo.register(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
        role: role,
      ));

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  /// Shared logic: show loading, catch errors, update the user
  Future<bool> _run(Future<User> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Could not connect to the server';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}