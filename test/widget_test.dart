import 'package:flutter_test/flutter_test.dart';
import 'package:mini_foot_owner_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OwnerApp());
    expect(find.byType(OwnerApp), findsOneWidget);
  });
}
