import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class FakeKosRepository extends KosRepository {
  final List<KosModel> dummyList;
  final bool shouldThrow;

  FakeKosRepository({this.dummyList = const [], this.shouldThrow = false});

  @override
  Future<List<KosModel>> getKosList() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return dummyList;
  }
}

void main() {
  group('KosProvider Tests (US01-AC1, US01-AC3)', () {
    final sampleKos = [
      const KosModel(
        id: '1',
        ownerId: 'u1',
        name: 'Kos Sejahtera',
        area: 'Singaraja Timur',
        type: 'Putra',
        pricePerMonth: 800000,
        availableRooms: 3,
        facilities: ['Wi-Fi', 'Kasur'],
        contactNumber: '081234567890',
      ),
      const KosModel(
        id: '2',
        ownerId: 'u2',
        name: 'Kos Cantika',
        area: 'Singaraja Barat',
        type: 'Putri',
        pricePerMonth: 1200000,
        availableRooms: 0,
        facilities: ['Wi-Fi', 'AC', 'Kamar Mandi Dalam'],
        contactNumber: '089876543210',
      ),
    ];

    test('US01-AC1: Berhasil memuat daftar kos', () async {
      final repo = FakeKosRepository(dummyList: sampleKos);
      final provider = KosProvider(repository: repo);

      expect(provider.isLoading, false);
      final future = provider.fetchKosList();
      expect(provider.isLoading, true);
      await future;

      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.kosList.length, 2);
      expect(provider.kosList.first.name, 'Kos Sejahtera');
    });

    test('US01-AC3: Menangani kegagalan jaringan saat memuat kos', () async {
      final repo = FakeKosRepository(shouldThrow: true);
      final provider = KosProvider(repository: repo);

      await provider.fetchKosList();

      expect(provider.isLoading, false);
      expect(provider.errorMessage, contains('Gagal memuat data'));
      expect(provider.kosList, isEmpty);
    });
  });
}
