
import 'package:inspectable_property/inspectable.dart';

class InspectableObject with Inspectable {

  int intValue;
  double doubleValue;
  bool boolValue;
  String stringValue;

  InspectableObject({this.intValue=0, this.doubleValue=0.0, this.boolValue=false, this.stringValue=''}) {
    properties.addAll([
      InspectableProperty<int>(name: 'intValue', getValue: (obj) => intValue, setValue: (obj, value, customData) => intValue = value,),
      InspectableProperty<double>(name: 'doubleValue', getValue: (obj) => doubleValue, setValue: (obj, value, customData) => doubleValue = value,),
      InspectableProperty<bool>(name: 'boolValue', getValue: (obj) => boolValue, setValue: (obj, value, customData) => boolValue = value,),
      InspectableProperty<String>(name: 'stringValue', getValue: (obj) => stringValue, setValue: (obj, value, customData) => stringValue = value,),
    ]);
  }

  @override
  String toString() {
    return 'int: $intValue\ndouble: $doubleValue\nbool: $boolValue\nstring: $stringValue';
  }
}