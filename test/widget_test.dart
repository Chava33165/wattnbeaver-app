import 'package:flutter_test/flutter_test.dart';
import 'package:wattnbeaver/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WattBeaverApp());
    expect(find.text('WattBeaver'), findsOneWidget);
  });
}
