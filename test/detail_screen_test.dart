import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/screens/detail_screen.dart';

void main() {
  testWidgets('US03-AC1: Menampilkan detail kos dengan kamar tersedia dan kontak',
      (WidgetTester tester) async {
    const kos = KosModel(
      id: 'k1',
      ownerId: 'u1',
      name: 'Kos Bunga Kenanga',
      area: 'Banyuasri, Singaraja',
      type: 'Putri',
      pricePerMonth: 850000,
      availableRooms: 3,
      facilities: ['Wi-Fi', 'AC', 'Kasur'],
      contactNumber: '081234567899',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DetailScreen(kos: kos),
      ),
    );

    expect(find.text('Kos Bunga Kenanga'), findsWidgets);
    expect(find.text('Banyuasri, Singaraja'), findsOneWidget);
    expect(find.text('Tersedia 3 Kamar'), findsOneWidget);
    expect(find.text('081234567899'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('AC'), findsOneWidget);
    expect(find.text('Kasur'), findsOneWidget);
  });

  testWidgets('US03-AC2: Menampilkan badge Penuh saat available_rooms = 0',
      (WidgetTester tester) async {
    const kos = KosModel(
      id: 'k2',
      ownerId: 'u2',
      name: 'Kos Penuh Damai',
      area: 'Kampus Undiksha',
      type: 'Putra',
      pricePerMonth: 600000,
      availableRooms: 0,
      facilities: ['Parkir Motor'],
      contactNumber: '089988776655',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DetailScreen(kos: kos),
      ),
    );

    expect(find.text('Penuh'), findsOneWidget);
    expect(find.text('089988776655'), findsOneWidget);
  });
}
