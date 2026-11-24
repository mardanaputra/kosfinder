import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:provider/provider.dart';

class FakeKosRepository extends KosRepository {
  final List<KosModel> items;

  FakeKosRepository(this.items);

  @override
  Future<List<KosModel>> getKosList() async => items;
}

void main() {
  final testData = [
    const KosModel(
      id: 'k1',
      ownerId: 'u1',
      name: 'Kos Undiksha 1',
      area: 'Singaraja Kampus Bawah',
      type: 'Putra',
      pricePerMonth: 800000,
      availableRooms: 2,
      facilities: ['Wi-Fi'],
      contactNumber: '081234567890',
    ),
    const KosModel(
      id: 'k2',
      ownerId: 'u2',
      name: 'Kos Pantai Penimbangan',
      area: 'Banyuasri Singaraja',
      type: 'Putri',
      pricePerMonth: 1200000,
      availableRooms: 1,
      facilities: ['AC'],
      contactNumber: '081234567891',
    ),
  ];

  Widget createWidget() {
    return ChangeNotifierProvider(
      create: (_) => KosProvider(repository: FakeKosRepository(testData)),
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('US01-AC2: Pencarian area menampilkan hasil yang cocok dan pesan saat kosong',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    // Awal: kedua kos tampil
    expect(find.text('Kos Undiksha 1'), findsOneWidget);
    expect(find.text('Kos Pantai Penimbangan'), findsOneWidget);

    // Cari area "Banyuasri"
    await tester.enterText(find.byType(TextField), 'Banyuasri');
    await tester.pumpAndSettle();

    expect(find.text('Kos Pantai Penimbangan'), findsOneWidget);
    expect(find.text('Kos Undiksha 1'), findsNothing);

    // Cari area yang tidak ada "AreaTidakAda"
    await tester.enterText(find.byType(TextField), 'AreaTidakAda');
    await tester.pumpAndSettle();

    expect(find.text('Kos di area tersebut tidak ditemukan'), findsOneWidget);
  });
}
