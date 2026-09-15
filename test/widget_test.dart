import 'package:flutter_test/flutter_test.dart';
import 'package:droniva/main.dart';

void main() {
  testWidgets('DronivaApp metronome smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DronivaApp());
    expect(find.text('DRONIVA PACER'), findsOneWidget);
    expect(find.text('ENGAGE RUNNER CADENCE'), findsOneWidget);
  });
}
