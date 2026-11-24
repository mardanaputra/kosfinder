import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/home_screen.dart';
import 'package:provider/provider.dart';

class MockKosRepository extends KosRepository {
  final List<KosModel> mockData;
  final bool shouldFail;

  MockKosRepository({this.mockData = const [], this.shouldFail = false});

  @override
  Future<List<KosModel>> getKosList() async {
    if (shouldFail) throw Exception('Network disconnected');
    return mockData;
  }
}

void main() {
  Widget createWidgetUnderTest(KosRepository repo) {
    return ChangeNotifierProvider(
      create: (_) => KosProvider(repository: repo),
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('US01-AC1: Menampilkan daftar kartu kos di HomeScreen',
      (WidgetTester tester) async {
    final sample = [
      const KosModel(
        id: '1',
        ownerId: 'u1',
        name: 'Kos Singaraja Indah',
        area: 'Singaraja',
        type: 'Putra',
        pricePerMonth: 750000,
        availableRooms: 2,
        facilities: ['Wi-Fi'],
        contactNumber: '081234567890',
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(MockKosRepository(mockData: sample)));
    await tester.pumpAndSettle();

    expect(find.text('Kos Singaraja Indah'), findsOneWidget);
    expect(find.text('Singaraja'), findsOneWidget);
    expect(find.text('Tersedia 2 Kamar'), findsOneWidget);
    expect(find.text('Rp 750.000 / bulan'), findsOneWidget);
  });

  testWidgets('US01-AC3: Menampilkan pesan error dan tombol Coba Lagi saat koneksi gagal',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(MockKosRepository(shouldFail: true)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat data'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
