import 'package:flutter/material.dart';
import 'package:inspectable_property/inspectable.dart';

enum TestEnum { value1, value2, value3 }

class TestClass with Inspectable {
  int intValue = 42;
  double doubleValue = 3.14;
  bool boolValue = true;
  String stringValue = 'hello';

  TestClass() {
    properties.addAll([
      InspectableProperty<int>(
        name: 'intValue',
        getValue: (obj) => (obj as TestClass).intValue,
        setValue: (obj, value, _) => (obj as TestClass).intValue = value,
      ),
      InspectableProperty<double>(
        name: 'doubleValue',
        getValue: (obj) => (obj as TestClass).doubleValue,
        setValue: (obj, value, _) => (obj as TestClass).doubleValue = value,
      ),
      InspectableProperty<bool>(
        name: 'boolValue',
        getValue: (obj) => (obj as TestClass).boolValue,
        setValue: (obj, value, _) => (obj as TestClass).boolValue = value,
      ),
      InspectableProperty<String>(
        name: 'stringValue',
        getValue: (obj) => (obj as TestClass).stringValue,
        setValue: (obj, value, _) => (obj as TestClass).stringValue = value,
      ),
    ]);
  }
}

class TestClassWithEnum with Inspectable {
  TestEnum enumValue = TestEnum.value1;
  int intValue = 10;

  TestClassWithEnum() {
    properties.addAll([
      InspectableProperty<Enum>(
        name: 'enumValue',
        getValue: (obj) => (obj as TestClassWithEnum).enumValue,
        setValue: (obj, value, _) => (obj as TestClassWithEnum).enumValue = value,
        values: () => TestEnum.values,
      ),
      InspectableProperty<int>(
        name: 'intValue',
        getValue: (obj) => (obj as TestClassWithEnum).intValue,
        setValue: (obj, value, _) => (obj as TestClassWithEnum).intValue = value,
      ),
    ]);
  }
}

Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}
