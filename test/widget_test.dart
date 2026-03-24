import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:transport_fleet_management/main.dart';

void main() {
  testWidgets('Dashboard flow screen opens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FleetApp()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('End-to-End Flow'), findsOneWidget);
  });
}
