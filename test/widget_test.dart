import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filament_manager/main.dart';

void main() {
  testWidgets('FilaManager app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FilaManagerApp());

    expect(find.text('FilaManager AI'), findsOneWidget);
  });
}
