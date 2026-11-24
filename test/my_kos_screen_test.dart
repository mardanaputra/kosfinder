import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/my_kos_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepo extends AuthRepository {
  final User? user;
  FakeAuthRepo(this.user);

  @override
  User? get currentUser => user;
}

class FakeKosRepo extends KosRepository {
  final List<KosModel> items;
  FakeKosRepo(this.items);

  @override
  Future<List<KosModel>> getKosList() async => items;
}

void main() {
  final ownerUser = User(
    id: 'owner-123',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'owner@test.com',
  );

  Widget createWidget({required List<KosModel> kosItems}) {
    final authRepo = FakeAuthRepo(ownerUser);
    final kosRepo = FakeKosRepo(kosItems);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(repository: authRepo)),
        ChangeNotifierProvider(
            create: (_) => KosProvider(repository: kosRepo)..fetchKosList()),
      ],
      child: const MaterialApp(home: MyKosScreen()),
    );
  }

  group('T10: MyKosScreen Tests (US06-AC1, US06-AC2)', () {
    testWidgets('US06-AC1: Menampilkan daftar kos milik sendiri',
        (WidgetTester tester) async {
      final sample = [
        const KosModel(
          id: 'k1',
          ownerId: 'owner-123',
          name: 'Kos Milik Saya 1',
          area: 'Singaraja',
          type: 'Putri',
          pricePerMonth: 800000,
          availableRooms: 2,
          facilities: ['Wi-Fi'],
          contactNumber: '081234567890',
        ),
        const KosModel(
          id: 'k2',
          ownerId: 'other-user',
          name: 'Kos Milik Orang Lain',
          area: 'Denpasar',
          type: 'Putra',
          pricePerMonth: 1000000,
          availableRooms: 1,
          facilities: ['AC'],
          contactNumber: '081234567891',
        ),
      ];

      await tester.pumpWidget(createWidget(kosItems: sample));
      await tester.pumpAndSettle();

      expect(find.text('Kos Milik Saya 1'), findsOneWidget);
      expect(find.text('Kos Milik Orang Lain'), findsNothing);
    });

    testWidgets('US06-AC2: Tampil pesan empty state bila belum memiliki kos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(kosItems: []));
      await tester.pumpAndSettle();

      expect(find.text('Anda belum memiliki properti kos yang terdaftar'),
          findsOneWidget);
      expect(find.text('Tambah Kos Sekarang'), findsOneWidget);
    });
  });
}
