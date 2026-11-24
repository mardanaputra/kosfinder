import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/about_screen.dart';

void main() {
  testWidgets('T05: Menampilkan identitas pengembang NIM dan Nama di AboutScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AboutScreen(),
      ),
    );

    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('Suniaramana Mardana Putra'), findsOneWidget);
    expect(find.text('2455011006'), findsOneWidget);
  });
}
