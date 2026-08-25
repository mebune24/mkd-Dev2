import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:space_rentals/main.dart';

void main() {
  testWidgets('SpaceRentals smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceRentalsApp());
    expect(find.byType(MaterialApp), findsNothing);
  });
}
