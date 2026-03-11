/// Mixin that gives a class runtime property inspection capabilities.
///
/// Mix this into any class and populate [properties] — typically inside the
/// constructor — with [InspectableProperty] descriptors for each field you
/// want to expose. The [Inspector] widget will read these descriptors to
/// render type-aware editors automatically.
///
/// ```dart
/// class Enemy with Inspectable {
///   int health = 100;
///
///   Enemy() {
///     properties.add(
///       InspectableProperty<int>(
///         name: 'health',
///         getValue: (obj) => health,
///         setValue: (obj, value, _) => health = value,
///       ),
///     );
///   }
/// }
/// ```
mixin Inspectable {

  /// The list of inspectable property descriptors for this object.
  ///
  /// Populate this list — usually inside the class constructor — with one
  /// [InspectableProperty] per field you want the [Inspector] to display.
  List<InspectableProperty> properties = [];

  /// Removes the property with the given [name] from [properties].
  ///
  /// Does nothing if no property with that name exists.
  void removeProperty(String name) {
    properties.removeWhere((element) => element.name==name,);
  }

  /// Returns the first property whose [InspectableProperty.name] matches
  /// [name], or `null` if no such property exists.
  InspectableProperty? getProperty(String name) {
    for (var property in properties) {
      if (property.name == name) {
        return property;
      }
    }
    return null;
  }
}

/// Describes a single inspectable field of type [T] on an [Inspectable] object.
///
/// An [InspectableProperty] pairs a getter/setter with metadata that controls
/// how the [Inspector] widget presents and validates the value:
///
/// - [readOnly] — renders the editor as non-interactive.
/// - [nullable] — allows `null`; bool editors render in tristate mode.
/// - [clamp] — min/max range; double editors render a [Slider].
/// - [values] — fixed set of allowed values; used by enum/dropdown editors.
/// - [customEditor] — key that selects a per-property custom editor.
/// - [getSubProperties] — returns nested descriptors for hierarchical inspection.
class InspectableProperty<T> {
  /// Whether this property should be rendered as read-only in the inspector.
  ///
  /// When `true`, the editor widget is displayed but user interaction is
  /// disabled.
  bool readOnly;

  /// The label displayed for this property in the inspector table.
  String name;

  /// Whether this property accepts `null` as a valid value.
  ///
  /// When `true`, bool editors render in tristate mode and string editors
  /// treat an empty field as `null`.
  bool nullable;

  /// Reads the current value of this property from [obj].
  ///
  /// Returns `null` when the value has not been set or when the property is
  /// [nullable] and currently holds `null`.
  T? Function(Inspectable obj) getValue;

  /// Writes [value] back to [obj].
  ///
  /// The [customData] argument is forwarded from [Inspector.customData],
  /// allowing the call site to pass arbitrary context (e.g. an undo stack).
  /// May be `null` for read-only properties.
  void Function(Inspectable obj, dynamic value, Object? customData)? setValue;

  /// Returns the exhaustive list of allowed values for this property.
  ///
  /// Required for [Enum] properties so the editor can populate its
  /// [DropdownButton]. May also be used by custom editors for any type.
  List<T> Function()? values;

  /// Optional inclusive (min, max) range for numeric properties.
  ///
  /// When set on a `double` property, the inspector renders a [Slider]
  /// instead of a [TextField].
  (T, T)? clamp;

  /// Returns nested [InspectableProperty] descriptors for a sub-object.
  ///
  /// Use this to support hierarchical (tree-style) inspection. The inspector
  /// will recurse into the sub-properties and render them indented below the
  /// parent row.
  List<InspectableProperty> Function(Inspectable obj)? getSubProperties;

  /// Key used to look up a per-property custom editor in the [Inspector]
  /// editors map, overriding the type-based lookup.
  String? customEditor;

  /// The Dart [Type] of this property, derived from the generic parameter [T].
  ///
  /// Used by [Inspector] to select the correct [EditorBuilder] from its
  /// editors map without requiring a concrete value to inspect.
  Type get type => T;

  /// Creates an [InspectableProperty] descriptor.
  ///
  /// [name] and [getValue] are required. All other parameters are optional
  /// and default to permissive values (`readOnly: false`, `nullable: false`).
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
