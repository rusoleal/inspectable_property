import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editors/editor_double.dart';
import 'package:inspectable_property/inspectable.dart';
import '../test_helpers.dart';

void main() {
  group('EditorDouble - TextField mode (no clamp)', () {
    testWidgets('displays initial value', (tester) async {
      final obj = TestClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '3.14');
    });

    testWidgets('valid input updates property', (tester) async {
      final obj = TestClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '2.5');
      await tester.pump();
      expect(obj.doubleValue, 2.5);
    });

    testWidgets('invalid input (letters) does not update non-nullable property',
        (tester) async {
      final obj = TestClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(obj.doubleValue, 3.14);
    });

    testWidgets('nullable empty input sets null', (tester) async {
      final obj = _NullableDoubleClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(obj.doubleValue, isNull);
    });

    testWidgets('readOnly prevents editing', (tester) async {
      final obj = _ReadOnlyDoubleClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, true);
    });

    testWidgets('multi-object different values shows empty', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj2.doubleValue = 9.99;
      final editor = EditorDouble(
        owners: [obj1, obj2],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '');
    });

    testWidgets('multi-object updates all owners', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      final editor = EditorDouble(
        owners: [obj1, obj2],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      await tester.enterText(find.byType(TextField), '7.7');
      await tester.pump();
      expect(obj1.doubleValue, 7.7);
      expect(obj2.doubleValue, 7.7);
    });
  });

  group('EditorDouble - Slider mode (clamp set, single owner)', () {
    testWidgets('renders Slider when clamp is set and single owner',
        (tester) async {
      final obj = _ClampedDoubleClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('slider respects min/max from clamp', (tester) async {
      final obj = _ClampedDoubleClass();
      final editor = EditorDouble(
        owners: [obj],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.min, 0.0);
      expect(slider.max, 10.0);
    });

    testWidgets('multi-owner with clamp falls back to TextField',
        (tester) async {
      final obj1 = _ClampedDoubleClass();
      final obj2 = _ClampedDoubleClass();
      final editor = EditorDouble(
        owners: [obj1, obj2],
        propertyName: 'doubleValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Slider), findsNothing);
    });
  });
}

class _NullableDoubleClass with Inspectable {
  double? doubleValue = 5.0;

  _NullableDoubleClass() {
    properties.add(InspectableProperty<double>(
      name: 'doubleValue',
      getValue: (obj) => (obj as _NullableDoubleClass).doubleValue,
      setValue: (obj, value, _) =>
          (obj as _NullableDoubleClass).doubleValue = value,
      nullable: true,
    ));
  }
}

class _ReadOnlyDoubleClass with Inspectable {
  double doubleValue = 1.0;

  _ReadOnlyDoubleClass() {
    properties.add(InspectableProperty<double>(
      name: 'doubleValue',
      getValue: (obj) => (obj as _ReadOnlyDoubleClass).doubleValue,
      readOnly: true,
    ));
  }
}

class _ClampedDoubleClass with Inspectable {
  double doubleValue = 5.0;

  _ClampedDoubleClass() {
    properties.add(InspectableProperty<double>(
      name: 'doubleValue',
      getValue: (obj) => (obj as _ClampedDoubleClass).doubleValue,
      setValue: (obj, value, _) =>
          (obj as _ClampedDoubleClass).doubleValue = value,
      clamp: (0.0, 10.0),
    ));
  }
}
