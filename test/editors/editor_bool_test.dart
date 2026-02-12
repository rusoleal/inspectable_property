import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editors/editor_bool.dart';
import 'package:inspectable_property/inspectable.dart';
import '../test_helpers.dart';

void main() {
  group('EditorBool', () {
    testWidgets('displays checked when value is true', (tester) async {
      final obj = TestClass();
      obj.boolValue = true;
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('displays unchecked when value is false', (tester) async {
      final obj = TestClass();
      obj.boolValue = false;
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('toggle updates property', (tester) async {
      final obj = TestClass();
      obj.boolValue = true;
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(obj.boolValue, false);
    });

    testWidgets('multi-object differ shows null (indeterminate)',
        (tester) async {
      // Use nullable bool properties so tristate=true, allowing null value
      final obj1 = _NullableBoolClass();
      final obj2 = _NullableBoolClass();
      obj1.boolValue = true;
      obj2.boolValue = false;
      final editor = EditorBool(
        owners: [obj1, obj2],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isNull);
    });

    testWidgets('nullable property enables tristate', (tester) async {
      final obj = _NullableBoolClass();
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.tristate, true);
    });

    testWidgets('non-nullable property has tristate false', (tester) async {
      final obj = TestClass();
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.tristate, false);
    });

    testWidgets('readOnly prevents toggle', (tester) async {
      final obj = _ReadOnlyBoolClass();
      final editor = EditorBool(
        owners: [obj],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(obj.boolValue, true);
    });

    testWidgets('multi-object toggle updates all owners', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj1.boolValue = true;
      obj2.boolValue = true;
      final editor = EditorBool(
        owners: [obj1, obj2],
        propertyName: 'boolValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(obj1.boolValue, false);
      expect(obj2.boolValue, false);
    });
  });
}

class _NullableBoolClass with Inspectable {
  bool? boolValue = true;

  _NullableBoolClass() {
    properties.add(InspectableProperty<bool>(
      name: 'boolValue',
      getValue: (obj) => (obj as _NullableBoolClass).boolValue,
      setValue: (obj, value, _) =>
          (obj as _NullableBoolClass).boolValue = value,
      nullable: true,
    ));
  }
}

class _ReadOnlyBoolClass with Inspectable {
  bool boolValue = true;

  _ReadOnlyBoolClass() {
    properties.add(InspectableProperty<bool>(
      name: 'boolValue',
      getValue: (obj) => (obj as _ReadOnlyBoolClass).boolValue,
      setValue: (obj, value, _) =>
          (obj as _ReadOnlyBoolClass).boolValue = value,
      readOnly: true,
    ));
  }
}
