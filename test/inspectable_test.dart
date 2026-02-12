import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/inspectable.dart';
import 'test_helpers.dart';

void main() {
  group('Inspectable mixin', () {
    test('properties starts empty before initialization', () {
      final obj = _BareInspectable();
      expect(obj.properties, isEmpty);
    });

    test('getProperty returns property when found', () {
      final obj = TestClass();
      final prop = obj.getProperty('intValue');
      expect(prop, isNotNull);
      expect(prop!.name, 'intValue');
    });

    test('getProperty returns null when not found', () {
      final obj = TestClass();
      expect(obj.getProperty('nonExistent'), isNull);
    });

    test('removeProperty removes existing property', () {
      final obj = TestClass();
      expect(obj.getProperty('intValue'), isNotNull);
      obj.removeProperty('intValue');
      expect(obj.getProperty('intValue'), isNull);
    });

    test('removeProperty does nothing for non-existent property', () {
      final obj = TestClass();
      final count = obj.properties.length;
      obj.removeProperty('nonExistent');
      expect(obj.properties.length, count);
    });
  });

  group('InspectableProperty', () {
    test('constructor sets required fields', () {
      final prop = InspectableProperty<int>(
        name: 'test',
        getValue: (_) => 42,
      );
      expect(prop.name, 'test');
      expect(prop.getValue(_BareInspectable()), 42);
    });

    test('type getter returns int for InspectableProperty<int>', () {
      final prop = InspectableProperty<int>(
        name: 'test',
        getValue: (_) => 0,
      );
      expect(prop.type, int);
    });

    test('type getter returns double for InspectableProperty<double>', () {
      final prop = InspectableProperty<double>(
        name: 'test',
        getValue: (_) => 0.0,
      );
      expect(prop.type, double);
    });

    test('type getter returns bool for InspectableProperty<bool>', () {
      final prop = InspectableProperty<bool>(
        name: 'test',
        getValue: (_) => true,
      );
      expect(prop.type, bool);
    });

    test('type getter returns String for InspectableProperty<String>', () {
      final prop = InspectableProperty<String>(
        name: 'test',
        getValue: (_) => '',
      );
      expect(prop.type, String);
    });

    test('type getter returns Enum for InspectableProperty<Enum>', () {
      final prop = InspectableProperty<Enum>(
        name: 'test',
        getValue: (_) => TestEnum.value1,
      );
      expect(prop.type, Enum);
    });

    test('defaults: readOnly is false, nullable is false', () {
      final prop = InspectableProperty<int>(
        name: 'test',
        getValue: (_) => 0,
      );
      expect(prop.readOnly, false);
      expect(prop.nullable, false);
    });

    test('setValue callback works', () {
      int stored = 0;
      final prop = InspectableProperty<int>(
        name: 'test',
        getValue: (_) => stored,
        setValue: (_, value, __) => stored = value,
      );
      prop.setValue!(_BareInspectable(), 99, null);
      expect(stored, 99);
    });

    test('clamp is stored correctly', () {
      final prop = InspectableProperty<double>(
        name: 'test',
        getValue: (_) => 0.5,
        clamp: (0.0, 1.0),
      );
      expect(prop.clamp, (0.0, 1.0));
    });

    test('values callback is stored correctly', () {
      final prop = InspectableProperty<Enum>(
        name: 'test',
        getValue: (_) => TestEnum.value1,
        values: () => TestEnum.values,
      );
      expect(prop.values!(), TestEnum.values);
    });

    test('customEditor is stored correctly', () {
      final prop = InspectableProperty<int>(
        name: 'test',
        getValue: (_) => 0,
        customEditor: 'myEditor',
      );
      expect(prop.customEditor, 'myEditor');
    });

    test('getSubProperties callback is stored correctly', () {
      final subProp = InspectableProperty<int>(
        name: 'sub',
        getValue: (_) => 1,
      );
      final prop = InspectableProperty<int>(
        name: 'parent',
        getValue: (_) => 0,
        getSubProperties: (_) => [subProp],
      );
      expect(prop.getSubProperties!(_BareInspectable()), [subProp]);
    });
  });
}

class _BareInspectable with Inspectable {}
