import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockKosRepo extends KosRepository {
  @override
  Future<List<KosModel>> getKosList() async => [];
}

class MockAuthRepo extends AuthRepository {
  @override
  User? get currentUser => null;
}

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      kosRepository: MockKosRepo(),
      authRepository: MockAuthRepo(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('KosFinder'), findsOneWidget);
  });
}
