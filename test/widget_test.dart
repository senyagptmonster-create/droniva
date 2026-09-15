import 'package:flutter_test/flutter_test.dart';
import 'package:droniva/droniva_app.dart';

void main() {
  testWidgets('DronivaCadenceApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DronivaCadenceApp());
    expect(find.byType(DronivaCadenceApp), findsOneWidget);
  });
}