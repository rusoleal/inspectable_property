import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editor_base.dart';
import 'package:inspectable_property/inspectable.dart';
import 'package:inspectable_property/inspector.dart';
import 'test_helpers.dart';

void main() {
  group('Inspector', () {
    testWidgets('empty objects list renders empty table', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const Inspector(objects: [])),
      );
      // Table exists but no rows
      expect(find.byType(Table), findsOneWidget);
      expect(find.byType(TableRow), findsNothing);
    });

    testWidgets('null objects defaults to empty', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const Inspector()),
      );
      expect(find.byType(Table), findsOneWidget);
    });

    testWidgets('single object renders a row per property', (tester) async {
      final obj = TestClass();
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj])),
      );
      // TestClass has 4 properties: intValue, doubleValue, boolValue, stringValue
      // Each should have its name in the left column
      expect(find.text('intValue'), findsOneWidget);
      expect(find.text('doubleValue'), findsOneWidget);
      expect(find.text('boolValue'), findsOneWidget);
      expect(find.text('stringValue'), findsOneWidget);
    });

    testWidgets('property names appear in left column', (tester) async {
      final obj = TestClass();
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj])),
      );
      // Verify property names are displayed as Text widgets
      for (final name in ['intValue', 'doubleValue', 'boolValue', 'stringValue']) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('multi-object shows common property intersection',
        (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClassWithEnum();
      // Both have intValue, only TestClass has doubleValue/boolValue/stringValue,
      // only TestClassWithEnum has enumValue
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj1, obj2])),
      );
      expect(find.text('intValue'), findsOneWidget);
      expect(find.text('doubleValue'), findsNothing);
      expect(find.text('boolValue'), findsNothing);
      expect(find.text('stringValue'), findsNothing);
      expect(find.text('enumValue'), findsNothing);
    });

    testWidgets('custom editor is used for non-built-in type', (tester) async {
      final obj = _DurationClass();
      bool customEditorUsed = false;
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(
          objects: [obj],
          editors: {
            Duration: ({
              Key? key,
              required List<Inspectable> owners,
              required String propertyName,
              Object? customData,
              void Function(dynamic value)? onUpdatedProperty,
            }) {
              customEditorUsed = true;
              return EditorBase(
                key: key,
                owners: owners,
                propertyName: propertyName,
                customData: customData,
                onUpdatedProperty: onUpdatedProperty,
              );
            },
          },
        )),
      );
      expect(customEditorUsed, true);
    });

    testWidgets('onUpdatedProperty callback fires', (tester) async {
      final obj = TestClass();
      dynamic callbackValue;
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(
          objects: [obj],
          onUpdatedProperty: (properties, value) {
            callbackValue = value;
          },
        )),
      );
      // Find the int editor TextField and change its value
      // There are multiple TextFields; intValue is one of them
      final textFields = find.byType(TextField);
      // Enter a valid int into the first TextField
      await tester.enterText(textFields.first, '99');
      await tester.pump();
      expect(callbackValue, isNotNull);
    });

    testWidgets('keys cleared when object list changes', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj2.intValue = 100;

      // First render with obj1
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj1])),
      );
      expect(find.text('intValue'), findsOneWidget);

      // Change to obj2 - keys should be cleared and rebuilt
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj2])),
      );
      expect(find.text('intValue'), findsOneWidget);
    });

    testWidgets('enum property renders dropdown', (tester) async {
      final obj = TestClassWithEnum();
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj])),
      );
      expect(find.byType(DropdownButton<Enum>), findsOneWidget);
      expect(find.text('enumValue'), findsOneWidget);
    });

    testWidgets('two objects of same class show all properties',
        (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj1, obj2])),
      );
      expect(find.text('intValue'), findsOneWidget);
      expect(find.text('doubleValue'), findsOneWidget);
      expect(find.text('boolValue'), findsOneWidget);
      expect(find.text('stringValue'), findsOneWidget);
    });

    testWidgets('renders inside SingleChildScrollView', (tester) async {
      final obj = TestClass();
      await tester.pumpWidget(
        wrapWithMaterialApp(Inspector(objects: [obj])),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

class _DurationClass with Inspectable {
  Duration durationValue = const Duration(seconds: 5);

  _DurationClass() {
    properties.add(InspectableProperty<Duration>(
      name: 'durationValue',
      getValue: (obj) => (obj as _DurationClass).durationValue,
      setValue: (obj, value, _) =>
          (obj as _DurationClass).durationValue = value,
    ));
  }
}
