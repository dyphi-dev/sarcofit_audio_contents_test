import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:interactive_media_test/main.dart';

void main() {
  testWidgets('Interactive Media Test app smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Interactive Media Test'), findsOneWidget);
    expect(find.text('JSON Editor'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
  });
}