import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository extends AuthRepository {
  final bool shouldFail;
  final User? mockUser;

  MockAuthRepository({this.shouldFail = false, this.mockUser});

  @override
  User? get currentUser => mockUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthException('User already registered');
    }
    return AuthResponse(
      session: null,
      user: User(
        id: 'new-user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthException('Invalid login credentials');
    }
    return AuthResponse(
      session: null,
      user: User(
        id: 'user-logged-in-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('T08: AuthProvider Tests (US04-AC1, US04-AC2)', () {
    test('US04-AC1: Registrasi berhasil dengan email dan password valid',
        () async {
      final repo = MockAuthRepository();
      final provider = AuthProvider(repository: repo);

      final success = await provider.register('test@owner.com', 'password123');

      expect(success, true);
      expect(provider.isAuthenticated, true);
      expect(provider.currentUser?.email, 'test@owner.com');
      expect(provider.errorMessage, isNull);
    });

    test('US04-AC2: Login gagal menampilkan error email atau password salah',
        () async {
      final repo = MockAuthRepository(shouldFail: true);
      final provider = AuthProvider(repository: repo);

      final success = await provider.login('wrong@owner.com', 'wrongpassword');

      expect(success, false);
      expect(provider.isAuthenticated, false);
      expect(provider.errorMessage, 'Email atau password salah');
    });

    test('Logout mengosongkan status user', () async {
      final mockUser = User(
        id: 'u-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
      final repo = MockAuthRepository(mockUser: mockUser);
      final provider = AuthProvider(repository: repo);

      expect(provider.isAuthenticated, true);

      await provider.logout();

      expect(provider.isAuthenticated, false);
      expect(provider.currentUser, isNull);
    });
  });
}
