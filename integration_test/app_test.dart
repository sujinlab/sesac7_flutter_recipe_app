import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/01_stateless/presentation/screen/main/main_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('버튼을 누르면 값이 증가한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(),
      ),
    );

    expect(find.byKey(Key('count')), findsOneWidget);
    await tester.tap(find.byKey(Key('small_button')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byKey(Key('small_button')));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });
}
