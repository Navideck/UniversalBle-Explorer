import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_ble_example/peripheral_details/widgets/result_widget.dart';

Widget _wrap({
  required List<String> results,
  required ScrollController controller,
  ValueChanged<String>? onSubmitCustomLog,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ResultWidget(
        results: results,
        scrollController: controller,
        onClearTap: (_) {},
        onSubmitCustomLog: onSubmitCustomLog,
      ),
    ),
  );
}

void main() {
  testWidgets('submits trimmed custom log and clears the field', (tester) async {
    final submitted = <String>[];
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(
      results: const ['existing log'],
      controller: controller,
      onSubmitCustomLog: submitted.add,
    ));

    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.enterText(field, '  custom annotation  ');
    await tester.pump();

    await tester.tap(find.widgetWithIcon(IconButton, Icons.send));
    await tester.pump();

    expect(submitted, ['custom annotation']);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
  });

  testWidgets('does not submit empty input and disables send', (tester) async {
    final submitted = <String>[];
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(
      results: const ['existing log'],
      controller: controller,
      onSubmitCustomLog: submitted.add,
    ));

    IconButton sendButton() => tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.send),
        );

    expect(sendButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(sendButton().onPressed, isNull);
    expect(submitted, isEmpty);
  });

  testWidgets('hides input when callback is null', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(
      results: const ['existing log'],
      controller: controller,
    ));

    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.send), findsNothing);
  });
}
