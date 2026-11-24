import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepo extends AuthRepository {
  final User? user;
  FakeAuthRepo(this.user);

  @override
  User? get currentUser => user;
}

class FakeKosRepo extends KosRepository {
  KosModel? updatedKos;
  final bool shouldFailUnauthorized;

  FakeKosRepo({this.shouldFailUnauthorized = false});

  @override
  Future<KosModel> updateKos(KosModel kos) async {
    if (shouldFailUnauthorized) {
      throw const PostgrestException(
        message: 'new row violates row-level security policy for table "kos"',
        code: '42501',
      );
    }
    updatedKos = kos;
    return kos;
  }
}

void main() {
  final ownerUser = User(
    id: 'owner-me',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'me@kos.com',
  );

  final existingKos = const KosModel(
    id: 'kos-001',
    ownerId: 'owner-me',
    name: 'Kos Bunga Melati Asri',
    area: 'Singaraja Selatan',
    type: 'Putri',
    pricePerMonth: 800000,
    availableRooms: 2,
    facilities: ['Wi-Fi'],
    contactNumber: '08123456789',
  );

  Widget createWidget({required FakeKosRepo repo, KosModel? kosToEdit}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: FakeAuthRepo(ownerUser))),
        ChangeNotifierProvider(create: (_) => KosProvider(repository: repo)),
      ],
      child: MaterialApp(
        home: KosFormScreen(kos: kosToEdit ?? existingKos),
      ),
    );
  }

  group('T12: Ubah Kos Tests (US07-AC1, US07-AC2)', () {
    testWidgets('US07-AC1: Pemilik berhasil mengubah sisa kamar dari 2 menjadi 0',
        (WidgetTester tester) async {
      final repo = FakeKosRepo();
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      // Form terisi dengan data awal
      expect(find.text('Kos Bunga Melati Asri'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Ubah sisa kamar jadi 0
      await tester.enterText(find.byKey(const Key('rooms_field')), '0');

      final saveButton = find.byKey(const Key('save_button'));
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.updatedKos, isNotNull);
      expect(repo.updatedKos!.availableRooms, 0);
      expect(repo.updatedKos!.isAvailable, false);
      expect(find.text('Data kos berhasil diperbarui!'), findsOneWidget);
    });

    testWidgets('US07-AC2: Backend RLS menolak update kos (unauthorized error)',
        (WidgetTester tester) async {
      final repo = FakeKosRepo(shouldFailUnauthorized: true);
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const Key('save_button'));
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('row-level security policy'), findsOneWidget);
      expect(repo.updatedKos, isNull);
    });
  });
}
