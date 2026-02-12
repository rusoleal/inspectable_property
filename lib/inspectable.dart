/// Mixin that gives a class runtime property inspection capabilities.
///
/// Classes that use this mixin gain a [properties] list of
/// [InspectableProperty] descriptors, which can be consumed by the
/// [Inspector] widget to render type-aware editors.
mixin Inspectable {

  /// The list of inspectable property descriptors for this object.
  List<InspectableProperty> properties = [];

  /// Removes the property with the given [name] from [properties].
  void removeProperty(String name) {
    properties.removeWhere((element) => element.name==name,);
  }

  /// Returns the property with the given [name], or `null` if not found.
  InspectableProperty? getProperty(String name) {
    for (var property in properties) {
      if (property.name == name) {
        return property;
      }
    }
    return null;
  }
}

/// Describes a single inspectable property of type [T].
///
/// Holds a getter/setter pair, metadata (read-only, nullable, clamp range),
/// and optional configuration for custom editors and sub-properties.
class InspectableProperty<T> {
  /// Whether this property is read-only in the inspector UI.
  bool readOnly;

  /// The display name of this property.
  String name;

  /// Whether this property accepts `null` values.
  bool nullable;

  /// Returns the current value of this property for the given [obj].
  T? Function(Inspectable obj) getValue;

  /// Sets the value of this property on [obj]. The optional [customData]
  /// is forwarded from the [Inspector] widget.
  void Function(Inspectable obj, dynamic value, Object? customData)? setValue;

  /// Returns the list of allowed values for this property (used by enum and
  /// dropdown editors).
  List<T> Function()? values;

  /// An optional (min, max) range. When set on a `double` property, the
  /// editor renders a slider instead of a text field.
  (T, T)? clamp;

  /// Returns nested sub-properties for hierarchical inspection.
  List<InspectableProperty> Function(Inspectable obj)? getSubProperties;

  /// An optional key to select a custom editor by name instead of by type.
  String? customEditor;

  /// The Dart [Type] of this property, derived from the generic parameter [T].
  Type get type => T;

  /// Creates an [InspectableProperty] with the given [name] and [getValue] callback.
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
