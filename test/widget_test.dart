import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('KosFinder'), findsOneWidget);
  });
}
