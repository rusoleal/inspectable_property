import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editors/editor_string.dart';
import 'package:inspectable_property/inspectable.dart';
import '../test_helpers.dart';

void main() {
  group('EditorString', () {
    testWidgets('displays initial value', (tester) async {
      final obj = TestClass();
      final editor = EditorString(
        owners: [obj],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'hello');
    });

    testWidgets('input updates property', (tester) async {
      final obj = TestClass();
      final editor = EditorString(
        owners: [obj],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), 'world');
      await tester.pump();
      expect(obj.stringValue, 'world');
    });

    testWidgets('nullable: empty input sets null', (tester) async {
      final obj = _NullableStringClass();
      final editor = EditorString(
        owners: [obj],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(obj.stringValue, isNull);
    });

    testWidgets('non-nullable: empty input stays empty string',
        (tester) async {
      final obj = TestClass();
      final editor = EditorString(
        owners: [obj],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(obj.stringValue, '');
    });

    testWidgets('multi-object different values shows empty', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj2.stringValue = 'different';
      final editor = EditorString(
        owners: [obj1, obj2],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '');
    });

    testWidgets('readOnly prevents editing', (tester) async {
      final obj = _ReadOnlyStringClass();
      final editor = EditorString(
        owners: [obj],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, true);
    });

    testWidgets('multi-object updates all owners', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      final editor = EditorString(
        owners: [obj1, obj2],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), 'shared');
      await tester.pump();
      expect(obj1.stringValue, 'shared');
      expect(obj2.stringValue, 'shared');
    });
  });
}

class _NullableStringClass with Inspectable {
  String? stringValue = 'test';

  _NullableStringClass() {
    properties.add(InspectableProperty<String>(
      name: 'stringValue',
      getValue: (obj) => (obj as _NullableStringClass).stringValue,
      setValue: (obj, value, _) =>
          (obj as _NullableStringClass).stringValue = value,
      nullable: true,
    ));
  }
}

class _ReadOnlyStringClass with Inspectable {
  String stringValue = 'readonly';

  _ReadOnlyStringClass() {
    properties.add(InspectableProperty<String>(
      name: 'stringValue',
      getValue: (obj) => (obj as _ReadOnlyStringClass).stringValue,
      readOnly: true,
    ));
  }
}
