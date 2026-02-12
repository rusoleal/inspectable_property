import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editors/editor_enum.dart';
import 'package:inspectable_property/inspectable.dart';
import '../test_helpers.dart';

void main() {
  group('EditorEnum', () {
    testWidgets('dropdown shows all enum values', (tester) async {
      final obj = TestClassWithEnum();
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      // All 3 enum values should be visible
      expect(find.text('value1'), findsWidgets);
      expect(find.text('value2'), findsOneWidget);
      expect(find.text('value3'), findsOneWidget);
    });

    testWidgets('current value is selected', (tester) async {
      final obj = TestClassWithEnum();
      obj.enumValue = TestEnum.value2;
      // Need to re-register properties since the getValue reads live value
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      // The dropdown button should show value2
      final dropdown =
          tester.widget<DropdownButton<Enum>>(find.byType(DropdownButton<Enum>));
      expect(dropdown.value, TestEnum.value2);
    });

    testWidgets('selection updates property', (tester) async {
      final obj = TestClassWithEnum();
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('value3').last);
      await tester.pumpAndSettle();
      expect(obj.enumValue, TestEnum.value3);
    });

    testWidgets('nullable adds empty option', (tester) async {
      final obj = _NullableEnumClass();
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      // 3 enum values + 1 empty option = 4 items
      // The empty text item should be present
      expect(find.text(''), findsWidgets);
    });

    testWidgets('readOnly prevents change', (tester) async {
      final obj = _ReadOnlyEnumClass();
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('value2').last);
      await tester.pumpAndSettle();
      expect(obj.enumValue, TestEnum.value1);
    });

    testWidgets('multi-object selection updates all owners', (tester) async {
      final obj1 = TestClassWithEnum();
      final obj2 = TestClassWithEnum();
      final editor = EditorEnum(
        owners: [obj1, obj2],
        propertyName: 'enumValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('value2').last);
      await tester.pumpAndSettle();
      expect(obj1.enumValue, TestEnum.value2);
      expect(obj2.enumValue, TestEnum.value2);
    });

    testWidgets('onUpdateProperty callback fires on selection',
        (tester) async {
      final obj = TestClassWithEnum();
      dynamic callbackValue;
      final editor = EditorEnum(
        owners: [obj],
        propertyName: 'enumValue',
        onUpdatedProperty: (value) => callbackValue = value,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.tap(find.byType(DropdownButton<Enum>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('value3').last);
      await tester.pumpAndSettle();
      expect(callbackValue, TestEnum.value3);
    });
  });
}

class _NullableEnumClass with Inspectable {
  TestEnum? enumValue = TestEnum.value1;

  _NullableEnumClass() {
    properties.add(InspectableProperty<Enum>(
      name: 'enumValue',
      getValue: (obj) => (obj as _NullableEnumClass).enumValue,
      setValue: (obj, value, _) =>
          (obj as _NullableEnumClass).enumValue = value as TestEnum?,
      values: () => TestEnum.values,
      nullable: true,
    ));
  }
}

class _ReadOnlyEnumClass with Inspectable {
  TestEnum enumValue = TestEnum.value1;

  _ReadOnlyEnumClass() {
    properties.add(InspectableProperty<Enum>(
      name: 'enumValue',
      getValue: (obj) => (obj as _ReadOnlyEnumClass).enumValue,
      setValue: (obj, value, _) =>
          (obj as _ReadOnlyEnumClass).enumValue = value as TestEnum,
      values: () => TestEnum.values,
      readOnly: true,
    ));
  }
}
