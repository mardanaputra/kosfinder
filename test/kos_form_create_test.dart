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
  final List<KosModel> items = [];

  @override
  Future<KosModel> createKos(KosModel kos) async {
    final created = kos.copyWith(id: 'created-id-1');
    items.add(created);
    return created;
  }
}

void main() {
  final ownerUser = User(
    id: 'owner-abc',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'owner@abc.com',
  );

  Widget createWidget({required FakeKosRepo repo}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(repository: FakeAuthRepo(ownerUser))),
        ChangeNotifierProvider(
            create: (_) => KosProvider(repository: repo)),
      ],
      child: const MaterialApp(home: KosFormScreen()),
    );
  }

  group('T11: Tambah Kos Tests (US05-AC1, US05-AC2)', () {
    testWidgets('US05-AC2: Validasi form gagal saat nama kosong atau harga <= 0',
        (WidgetTester tester) async {
      final repo = FakeKosRepo();
      await tester.pumpWidget(createWidget(repo: repo));

      // Tekan tombol simpan saat form masih kosong
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
      expect(find.text('Area kos wajib diisi'), findsOneWidget);
      expect(find.text('Harga sewa wajib diisi'), findsOneWidget);

      // Isi harga dengan 0 atau negatif
      await tester.enterText(find.byKey(const Key('name_field')), 'Kos Baru');
      await tester.enterText(find.byKey(const Key('area_field')), 'Singaraja');
      await tester.enterText(find.byKey(const Key('price_field')), '0');
      await tester.enterText(find.byKey(const Key('contact_field')), '081234');

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Harga harus berupa angka lebih besar dari 0'),
          findsOneWidget);
      expect(repo.items, isEmpty);
    });

    testWidgets('US05-AC1: Tambah kos berhasil dengan input valid',
        (WidgetTester tester) async {
      final repo = FakeKosRepo();
      await tester.pumpWidget(createWidget(repo: repo));

      await tester.enterText(
          find.byKey(const Key('name_field')), 'Kos Mawar Indah');
      await tester.enterText(
          find.byKey(const Key('area_field')), 'Banyuning, Singaraja');
      await tester.enterText(find.byKey(const Key('price_field')), '850000');
      await tester.enterText(find.byKey(const Key('rooms_field')), '3');
      await tester.enterText(
          find.byKey(const Key('contact_field')), '081234567890');

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.items.length, 1);
      expect(repo.items.first.name, 'Kos Mawar Indah');
      expect(repo.items.first.ownerId, 'owner-abc');
      expect(repo.items.first.pricePerMonth, 850000);
      expect(find.text('Kos berhasil ditambahkan!'), findsOneWidget);
    });
  });
}
