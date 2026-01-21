
/// Add the inspectable mixin to give property inspection functionality to the class.
mixin Inspectable {

  /// inspectable property list.
  List<InspectableProperty> properties = [];

  void removeProperty(String name) {
    properties.removeWhere((element) => element.name==name,);
  }

  InspectableProperty? getProperty(String name) {
    for (var property in properties) {
      if (property.name == name) {
        return property;
      }
    }
    return null;
  }
}

class InspectableProperty<T> {
  bool readOnly;
  String name;
  bool nullable;
  T? Function(Inspectable obj) getValue;
  void Function(Inspectable obj, dynamic value, Object? customData)? setValue;
  List<T> Function()? values;
  (T, T)? clamp;
  List<InspectableProperty> Function(Inspectable obj)? getSubProperties;
  String? customEditor;
  Type get type => T;

  InspectableProperty({
    required this.name,
    required this.getValue,
    this.setValue,
    this.values,
    this.clamp,
    this.readOnly = false,
    this.nullable = false,
    this.getSubProperties,
    this.customEditor,
  });
}
