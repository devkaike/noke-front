import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noke_app/main.dart';

void main() {
  testWidgets('App loads and shows the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const NokeApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
