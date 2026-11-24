import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

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
      name: 'Kos Bunga Melati',
      area: 'Singaraja Timur',
      type: 'Putri',
      pricePerMonth: 950000,
      availableRooms: 2,
      facilities: ['Wi-Fi', 'AC', 'Kasur'],
      contactNumber: '081234567890',
    ),
    const KosModel(
      id: 'k2',
      ownerId: 'u2',
      name: 'Kos Garuda Jaya',
      area: 'Singaraja Barat',
      type: 'Putra',
      pricePerMonth: 800000,
      availableRooms: 3,
      facilities: ['Wi-Fi', 'Parkir Motor'],
      contactNumber: '081234567891',
    ),
    const KosModel(
      id: 'k3',
      ownerId: 'u3',
      name: 'Kos Anggrek Mewah',
      area: 'Singaraja Kota',
      type: 'Putri',
      pricePerMonth: 1500000,
      availableRooms: 1,
      facilities: ['Wi-Fi', 'AC', 'Kamar Mandi Dalam'],
      contactNumber: '081234567892',
    ),
  ];

  group('T07: Filter Tests (US02-AC1, US02-AC2)', () {
    test('US02-AC1: Filter kombinasi tipe Putri, harga <= 1.000.000, dan fasilitas Wi-Fi',
        () async {
      final provider = KosProvider(repository: FakeKosRepository(testData));
      await provider.fetchKosList();

      expect(provider.kosList.length, 3);

      provider.setFilter(
        selectedType: 'Putri',
        maxPrice: 1000000,
        selectedFacilities: ['Wi-Fi'],
      );

      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Bunga Melati');
      expect(provider.hasActiveFilter, true);
    });

    test('US02-AC2: Reset filter mengembalikan seluruh daftar kos', () async {
      final provider = KosProvider(repository: FakeKosRepository(testData));
      await provider.fetchKosList();

      provider.setFilter(
        selectedType: 'Putra',
        maxPrice: 900000,
      );
      expect(provider.kosList.length, 1);

      provider.resetFilter();

      expect(provider.kosList.length, 3);
      expect(provider.hasActiveFilter, false);
      expect(provider.maxPrice, isNull);
      expect(provider.selectedType, isNull);
      expect(provider.selectedFacilities, isEmpty);
    });
  });
}
