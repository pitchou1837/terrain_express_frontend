import 'package:terrain_express/core/api_client.dart';
import 'package:terrain_express/core/constants.dart';
import 'package:terrain_express/models/user.dart';

/// What any auth implementation must do
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  });
  Future<User?> currentUser();
  Future<void> logout();
}

/// Picks fake or real depending on AppConstants.useMock
AuthRepository createAuthRepository() =>
    AppConstants.useMock ? MockAuthRepository() : ApiAuthRepository();

// ---------------------------------------------------------------------------
// FAKE version — works without the backend
// Tip: log in with an email containing "owner" to test the owner side
// ---------------------------------------------------------------------------
class MockAuthRepository implements AuthRepository {
  User? _user;

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (password.length < 4) {
      throw ApiException(401, 'Wrong email or password');
    }
    _user = User(
      id: 1,
      name: email.split('@').first,
      email: email,
      phone: '0600000000',
      role: email.contains('owner') ? 'owner' : 'player',
    );
    await ApiClient.instance.saveToken('mock-token');
    return _user!;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _user = User(id: 1, name: name, email: email, phone: phone, role: role);
    await ApiClient.instance.saveToken('mock-token');
    return _user!;
  }

  @override
  Future<User?> currentUser() async => _user;

  @override
  Future<void> logout() async {
    _user = null;
    await ApiClient.instance.clearToken();
  }
}

// ---------------------------------------------------------------------------
// REAL version — calls Walid's FastAPI (adjust paths when his routes exist)
// ---------------------------------------------------------------------------
class ApiAuthRepository implements AuthRepository {
  final _api = ApiClient.instance;

  @override
  Future<User> login(String email, String password) async {
    final res = await _api.post('/auth/login',
        body: {'email': email, 'password': password});
    await _api.saveToken(res['access_token']);
    return (await currentUser())!;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    await _api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    });
    return login(email, password); // log in right after registering
  }

  @override
  Future<User?> currentUser() async {
    if (await _api.getToken() == null) return null;
    try {
      final res = await _api.get('/users/me');
      return User.fromJson(res);
    } catch (_) {
      await _api.clearToken(); // token expired or invalid
      return null;
    }
  }

  @override
  Future<void> logout() => _api.clearToken();
}