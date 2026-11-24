import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';

void main() {
  group('KosModel Tests', () {
    test('Membuat objek KosModel dan serialisasi JSON', () {
      final json = {
        'id': 'kos-123',
        'owner_id': 'user-456',
        'name': 'Kos Melati Indah',
        'area': 'Singaraja Barat',
        'type': 'Putri',
        'price_per_month': 850000,
        'available_rooms': 2,
        'facilities': ['Wi-Fi', 'AC', 'Kamar Mandi Dalam'],
        'contact_number': '081234567890',
        'created_at': '2026-11-24T00:00:00.000Z',
      };

      final kos = KosModel.fromJson(json);

      expect(kos.id, 'kos-123');
      expect(kos.ownerId, 'user-456');
      expect(kos.name, 'Kos Melati Indah');
      expect(kos.area, 'Singaraja Barat');
      expect(kos.type, 'Putri');
      expect(kos.pricePerMonth, 850000);
      expect(kos.availableRooms, 2);
      expect(kos.isAvailable, true);
      expect(kos.facilities, contains('Wi-Fi'));
      expect(kos.contactNumber, '081234567890');

      final serialized = kos.toJson();
      expect(serialized['id'], 'kos-123');
      expect(serialized['name'], 'Kos Melati Indah');
      expect(serialized['price_per_month'], 850000);
    });

    test('isAvailable bernilai false ketika available_rooms = 0', () {
      final kos = KosModel(
        id: 'kos-0',
        ownerId: 'user-0',
        name: 'Kos Penuh',
        area: 'Singaraja',
        type: 'Campur',
        pricePerMonth: 500000,
        availableRooms: 0,
        facilities: ['Kasur'],
        contactNumber: '0811111111',
      );

      expect(kos.isAvailable, false);
    });
  });
}
