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
  Future<List<KosModel>> getKosList() async => List.from(items);

  @override
  Future<KosModel> updateKos(KosModel kos) async {
    final index = items.indexWhere((k) => k.id == kos.id);
    if (index != -1) {
      items[index] = kos;
    }
    return kos;
  }
}

void main() {
  final ownerUser = User(
    id: 'owner-quick',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'quick@owner.com',
  );

  Widget createWidget({required FakeKosRepo repo}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: FakeAuthRepo(ownerUser))),
        ChangeNotifierProvider(
            create: (_) => KosProvider(repository: repo)..fetchKosList()),
      ],
      child: const MaterialApp(home: MyKosScreen()),
    );
  }

  group('T14: Pembaruan Cepat Ketersediaan Kamar (US03-AC1, US03-AC2, US07-AC1)',
      () {
    testWidgets(
        'Mengurangi kamar dari 1 menjadi 0 mengubah badge status menjadi Penuh',
        (WidgetTester tester) async {
      final sample = [
        const KosModel(
          id: 'kos-q1',
          ownerId: 'owner-quick',
          name: 'Kos Cepat Update',
          area: 'Singaraja Barat',
          type: 'Putra',
          pricePerMonth: 650000,
          availableRooms: 1,
          facilities: ['Kasur'],
          contactNumber: '081234',
        ),
      ];

      final repo = FakeKosRepo(sample);
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Sisa 1 Kamar'), findsOneWidget);

      // Tekan tombol decrement
      await tester.tap(find.byKey(const Key('decrement_rooms_kos-q1')));
      await tester.pumpAndSettle();

      expect(find.text('Penuh'), findsOneWidget);
      expect(repo.items.first.availableRooms, 0);
    });

    testWidgets('Menambah kamar dari 0 menjadi 1 mengubah status menjadi tersedia',
        (WidgetTester tester) async {
      final sample = [
        const KosModel(
          id: 'kos-q2',
          ownerId: 'owner-quick',
          name: 'Kos Awal Penuh',
          area: 'Singaraja Timur',
          type: 'Putri',
          pricePerMonth: 800000,
          availableRooms: 0,
          facilities: ['AC'],
          contactNumber: '081234',
        ),
      ];

      final repo = FakeKosRepo(sample);
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Penuh'), findsOneWidget);

      // Tekan tombol increment
      await tester.tap(find.byKey(const Key('increment_rooms_kos-q2')));
      await tester.pumpAndSettle();

      expect(find.text('Sisa 1 Kamar'), findsOneWidget);
      expect(repo.items.first.availableRooms, 1);
    });
  });
}
