import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editors/editor_int.dart';
import 'package:inspectable_property/inspectable.dart';
import '../test_helpers.dart';

void main() {
  group('EditorInt', () {
    testWidgets('displays initial value', (tester) async {
      final obj = TestClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '42');
    });

    testWidgets('valid input updates property', (tester) async {
      final obj = TestClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(obj.intValue, 100);
    });

    testWidgets('invalid input (letters) does not update property',
        (tester) async {
      final obj = TestClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(obj.intValue, 42);
    });

    testWidgets('invalid input (decimal) does not update property',
        (tester) async {
      final obj = TestClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '3.14');
      await tester.pump();
      expect(obj.intValue, 42);
    });

    testWidgets('negative and zero values work', (tester) async {
      final obj = TestClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '-5');
      await tester.pump();
      expect(obj.intValue, -5);

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();
      expect(obj.intValue, 0);
    });

    testWidgets('multi-object updates all owners', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      final editor = EditorInt(
        owners: [obj1, obj2],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '77');
      await tester.pump();
      expect(obj1.intValue, 77);
      expect(obj2.intValue, 77);
    });

    testWidgets('multi-object different values shows empty', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj2.intValue = 99;
      final editor = EditorInt(
        owners: [obj1, obj2],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '');
    });

    testWidgets('readOnly property prevents updating', (tester) async {
      final obj = _ReadOnlyIntClass();
      final editor = EditorInt(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(obj.intValue, 42);
    });
  });
}

class _ReadOnlyIntClass with Inspectable {
  int intValue = 42;

  _ReadOnlyIntClass() {
    properties.add(InspectableProperty<int>(
      name: 'intValue',
      getValue: (obj) => (obj as _ReadOnlyIntClass).intValue,
      setValue: (obj, value, _) => (obj as _ReadOnlyIntClass).intValue = value,
      readOnly: true,
    ));
  }
}
