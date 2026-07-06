import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_simple_access_engine_example/main.dart';

void main() {
  testWidgets('example app widget tree builds', (tester) async {
    await tester.pumpWidget(const DemoApp());
    expect(find.text('ABAC Demo Dashboard'), findsOneWidget);
  });
}
