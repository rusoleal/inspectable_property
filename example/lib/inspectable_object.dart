
import 'package:inspectable_property/inspectable.dart';

enum TestEnum {
  enum1,
  enum2,
  enum3
}

class InspectableObject with Inspectable {

  int intValue;
  double doubleValue;
  bool boolValue;
  String stringValue;
  TestEnum enumValue;


  InspectableObject({
    this.intValue=0,
    this.doubleValue=0.0,
    this.boolValue=false,
    this.stringValue='',
    this.enumValue=.enum1
  }) {
    properties.addAll([
      InspectableProperty<int>(name: 'intValue', getValue: (obj) => intValue, setValue: (obj, value, customData) => intValue = value,),
      InspectableProperty<double>(name: 'doubleValue', getValue: (obj) => doubleValue, setValue: (obj, value, customData) => doubleValue = value,),
      InspectableProperty<bool>(name: 'boolValue', getValue: (obj) => boolValue, setValue: (obj, value, customData) => boolValue = value,),
      InspectableProperty<String>(name: 'stringValue', getValue: (obj) => stringValue, setValue: (obj, value, customData) => stringValue = value,),
      InspectableProperty<Enum>(name: 'enumValue', getValue: (obj) => enumValue, setValue: (obj, value, customData) => enumValue = value, values: () => TestEnum.values,),
    ]);
  }

  @override
  String toString() {
    return 'int: $intValue\ndouble: $doubleValue\nbool: $boolValue\nstring: $stringValue\nenum: ${enumValue.name}';
  }
}