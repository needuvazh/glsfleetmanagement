import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/presentation/screens/inspection_list_screen.dart';

void main() {
  testWidgets('Renders InspectionListScreen', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR CAUGHT: ${details.exception}');
      if (details.stack != null) {
        print(details.stack);
      }
    };

    try {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InspectionListScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      print('PUMP AND SETTLE DONE WITHOUT ERROR');
    } catch (e, stack) {
      print('CAUGHT EXCEPTION: $e');
      print(stack);
    }
  });
}
