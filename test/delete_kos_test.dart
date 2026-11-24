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
  Future<void> deleteKos(String id) async {
    items.removeWhere((k) => k.id == id);
  }
}

void main() {
  final ownerUser = User(
    id: 'owner-xyz',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'owner@xyz.com',
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

  group('T13: Hapus Kos Tests (US08-AC1, US08-AC2)', () {
    testWidgets('US08-AC2: Batal hapus kos saat memilih Batal di dialog',
        (WidgetTester tester) async {
      final sample = [
        const KosModel(
          id: 'kos-del-1',
          ownerId: 'owner-xyz',
          name: 'Kos Batal Hapus',
          area: 'Singaraja',
          type: 'Putra',
          pricePerMonth: 600000,
          availableRooms: 1,
          facilities: ['Kasur'],
          contactNumber: '081234',
        ),
      ];

      final repo = FakeKosRepo(sample);
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Kos Batal Hapus'), findsOneWidget);

      // Tekan tombol Hapus
      await tester.tap(find.byKey(const Key('delete_button_kos-del-1')));
      await tester.pumpAndSettle();

      // Dialog konfirmasi muncul
      expect(find.text('Konfirmasi Hapus'), findsOneWidget);

      // Tekan Batal
      await tester.tap(find.byKey(const Key('cancel_delete_button')));
      await tester.pumpAndSettle();

      // Dialog tertutup dan item kos tetap ada
      expect(find.text('Konfirmasi Hapus'), findsNothing);
      expect(find.text('Kos Batal Hapus'), findsOneWidget);
      expect(repo.items.length, 1);
    });

    testWidgets('US08-AC1: Konfirmasi Ya, Hapus menghapus kos secara permanen',
        (WidgetTester tester) async {
      final sample = [
        const KosModel(
          id: 'kos-del-2',
          ownerId: 'owner-xyz',
          name: 'Kos Pasti Hapus',
          area: 'Singaraja',
          type: 'Campur',
          pricePerMonth: 750000,
          availableRooms: 2,
          facilities: ['Wi-Fi'],
          contactNumber: '081234',
        ),
      ];

      final repo = FakeKosRepo(sample);
      await tester.pumpWidget(createWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Kos Pasti Hapus'), findsOneWidget);

      // Tekan tombol Hapus
      await tester.tap(find.byKey(const Key('delete_button_kos-del-2')));
      await tester.pumpAndSettle();

      // Tekan Ya, Hapus
      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      // Kos terhapus dari repo dan UI
      expect(repo.items, isEmpty);
      expect(find.text('Kos Pasti Hapus'), findsNothing);
      expect(find.text('Kos berhasil dihapus permanen!'), findsOneWidget);
    });
  });
}
