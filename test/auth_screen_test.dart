import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepo extends AuthRepository {
  final bool shouldFail;

  FakeAuthRepo({this.shouldFail = false});

  @override
  User? get currentUser => null;

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
        id: 'u1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthException('Failed signup');
    }
    return AuthResponse(
      session: null,
      user: User(
        id: 'u2',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }
}

void main() {
  Widget createAuthWidget(AuthRepository repo) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(repository: repo),
      child: const MaterialApp(
        home: AuthScreen(),
      ),
    );
  }

  group('T09: AuthScreen Tests (US04-AC1, US04-AC2)', () {
    testWidgets('Tampil tab Masuk dan Daftar', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidget(FakeAuthRepo()));

      expect(find.widgetWithText(Tab, 'Masuk'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Daftar'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    });

    testWidgets('US04-AC2: Login gagal menampilkan SnackBar error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidget(FakeAuthRepo(shouldFail: true)));

      await tester.enterText(
          find.byKey(const Key('login_email_field')), 'wrong@user.com');
      await tester.enterText(
          find.byKey(const Key('login_password_field')), 'wrongpass');

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email atau password salah'), findsOneWidget);
    });

    testWidgets('US04-AC1: Registrasi berhasil mengubah status menjadi login',
        (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidget(FakeAuthRepo(shouldFail: false)));

      // Pindah ke tab Daftar
      await tester.tap(find.widgetWithText(Tab, 'Daftar'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('register_email_field')), 'owner@baru.com');
      await tester.enterText(
          find.byKey(const Key('register_password_field')), 'password123');

      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // State masuk ke logged in view
      expect(find.text('Anda Sedang Masuk'), findsOneWidget);
    });
  });
}
