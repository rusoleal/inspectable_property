import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inspectable_property/editors/editor_bool.dart';
import 'package:inspectable_property/editors/editor_double.dart';
import 'package:inspectable_property/editors/editor_enum.dart';
import 'package:inspectable_property/editors/editor_int.dart';
import 'editor_base.dart';
import 'editors/editor_string.dart';
import 'inspectable.dart';

/// Factory function signature for creating property editor instances.
///
/// Used to register custom editors in [Inspector.editors], keyed by the
/// property's runtime [Type]. Each factory receives the owning objects and
/// property name, plus optional [customData] and an [onUpdatedProperty]
/// callback.
///
/// Example registration:
/// ```dart
/// Inspector(
///   objects: [myObj],
///   editors: {
///     MyType: ({key, required owners, required propertyName,
///               customData, onUpdatedProperty}) =>
///         MyTypeEditor(key: key, owners: owners, propertyName: propertyName),
///   },
/// )
/// ```
typedef EditorBuilder =
    EditorBase Function({
      Key? key,
      required List<Inspectable> owners,
      required String propertyName,
      Object? customData,
      void Function(dynamic value)? onUpdatedProperty,
    });

/// A widget that renders a table of type-aware editors for one or more
/// [Inspectable] objects.
///
/// When a single object is passed, every property registered in its
/// [Inspectable.properties] list is shown. When multiple objects are passed,
/// only properties **common to all objects** (same name and runtime type) are
/// displayed. Fields whose values differ across objects appear blank in the
/// editor; committing a change applies the new value to every object.
///
/// Built-in editors are provided for [int], [double], [bool], [String], and
/// [Enum]. Additional editors supplied via [editors] take precedence over the
/// built-ins. A property can also opt out of the type lookup by specifying a
/// [InspectableProperty.customEditor] key.
class Inspector extends StatefulWidget {
  /// Custom editor factories keyed by property [Type].
  ///
  /// Entries here override the corresponding built-in editor. To add support
  /// for an entirely new type, simply add an entry for that type.
  final Map<Type, EditorBuilder> editors;

  /// The [Inspectable] objects whose properties are displayed and edited.
  final List<Inspectable> objects;

  /// Arbitrary data passed through to each editor and ultimately to
  /// [InspectableProperty.setValue] on every change.
  final Object? customData;

  /// Called whenever any property value is committed through the inspector.
  ///
  /// The [properties] list is currently empty (reserved for future use); the
  /// [value] argument carries the newly committed value.
  final void Function(List<InspectableProperty> properties, dynamic value)?
  onUpdatedProperty;

  /// Creates an [Inspector].
  ///
  /// [objects] defaults to an empty list and [editors] defaults to an empty
  /// map when not provided.
  const Inspector({
    super.key,
    Map<Type, EditorBuilder>? editors,
    List<Inspectable>? objects,
    this.customData,
    this.onUpdatedProperty,
  }) : objects = objects ?? const [],
       editors = editors ?? const {};

  @override
  State<StatefulWidget> createState() {
    return InspectorState();
  }
}

/// State for the [Inspector] widget.
class InspectorState extends State<Inspector> {
  /// Snapshot of the objects list from the previous build.
  ///
  /// Compared against [Inspector.objects] each build to detect when the
  /// selection has changed, which clears the [keys] cache.
  late List<Inspectable> objects;

  /// Stable [GlobalKey]s keyed by property name.
  ///
  /// Reusing the same key across builds ensures editor widgets preserve their
  /// internal state (e.g. text cursor position) while the property list is
  /// re-rendered.
  final Map<String, Key> keys = {};

  /// The effective editor map, combining user-supplied editors with the
  /// built-in defaults.
  ///
  /// User-supplied entries (from [Inspector.editors]) are inserted first so
  /// they override built-ins for the same type.
  late Map<Type, EditorBuilder> editors;

  /// Initialises the effective [editors] map by merging user-supplied entries
  /// with the built-in editors for [int], [double], [bool], [String], and
  /// [Enum].
  ///
  /// User-supplied editors take precedence over built-ins.
  @override
  void initState() {
    super.initState();

    objects = widget.objects;
    editors = {}
      ..addAll(widget.editors)
      ..addAll({
        int:
            ({
              Key? key,
              required List<Inspectable> owners,
              required String propertyName,
              Object? customData,
              void Function(dynamic value)? onUpdatedProperty,
            }) => EditorInt(
              key: key,
              owners: owners,
              propertyName: propertyName,
              customData: customData,
              onUpdatedProperty: onUpdatedProperty,
            ),
        double:
            ({
          Key? key,
          required List<Inspectable> owners,
          required String propertyName,
          Object? customData,
          void Function(dynamic value)? onUpdatedProperty,
        }) => EditorDouble(
          key: key,
          owners: owners,
          propertyName: propertyName,
          customData: customData,
          onUpdatedProperty: onUpdatedProperty,
        ),
        bool:
            ({
          Key? key,
          required List<Inspectable> owners,
          required String propertyName,
          Object? customData,
          void Function(dynamic value)? onUpdatedProperty,
        }) => EditorBool(
          key: key,
          owners: owners,
          propertyName: propertyName,
          customData: customData,
          onUpdatedProperty: onUpdatedProperty,
        ),
        String:
            ({
          Key? key,
          required List<Inspectable> owners,
          required String propertyName,
          Object? customData,
          void Function(dynamic value)? onUpdatedProperty,
        }) => EditorString(
          key: key,
          owners: owners,
          propertyName: propertyName,
          customData: customData,
          onUpdatedProperty: onUpdatedProperty,
        ),
        Enum:
            ({
          Key? key,
          required List<Inspectable> owners,
          required String propertyName,
          Object? customData,
          void Function(dynamic value)? onUpdatedProperty,
        }) => EditorEnum(
          key: key,
          owners: owners,
          propertyName: propertyName,
          customData: customData,
          onUpdatedProperty: onUpdatedProperty,
        ),
      });
  }

  /// Forwards a property-change notification to [Inspector.onUpdatedProperty].
  void propertyUpdated(dynamic value) {
    if (widget.onUpdatedProperty != null) {
      widget.onUpdatedProperty!([], value);
    }
  }

  /// Builds a single [TableRow] for [propertyName], resolving the editor to
  /// use via the [editors] map.
  ///
  /// Resolution order:
  /// 1. Exact type match in [editors].
  /// 2. Fall back to [Enum] editor when the exact type is not registered but
  ///    the property type is an enum subtype.
  /// 3. Fall back to the read-only [EditorBase] when no editor is found.
  ///
  /// The [level] parameter increases the left-side indentation for nested
  /// sub-properties.
  TableRow populateProperty(
    List<Inspectable> owners,
    String propertyName,
    int level,
  ) {
    TableRow toReturn;
    EditorBase? editor;

    if (!keys.containsKey(propertyName)) {
      keys[propertyName] = GlobalKey();
    }
    Key? k = keys[propertyName];

    var property = owners[0].getProperty(propertyName) as InspectableProperty;
    //dynamic t = property.getValue(owners[0]);
    Type type = property.type;
    var editorBuilder = editors[type];
    if (editorBuilder == null && type is Enum) {
      type = Enum;
      editorBuilder = editors[type];
    }
    if (editorBuilder != null) {
      editor = editorBuilder(
        key: k,
        owners: owners,
        propertyName: propertyName,
        customData: widget.customData,
        onUpdatedProperty: propertyUpdated,
      );
    } else {
      editor = EditorBase(
        key: k,
        owners: owners,
        propertyName: propertyName,
        customData: widget.customData,
        onUpdatedProperty: propertyUpdated,
      );
    }

    toReturn = TableRow(
      key: UniqueKey(),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.0, right: 4.0 + level * 4.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(propertyName),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: editor.getWidget(context),
        ),
      ],
    );

    /*if (property.getSubProperties != null) {
      var subProperties = property.getSubProperties!(obj);
      toReturn.addAll(populateProperties(obj, subProperties, level+1));
    }*/

    return toReturn;
  }

  /// Returns a set of `(name, runtimeType)` pairs for all properties on [obj].
  ///
  /// The runtime type is obtained by reading the current value, so the set
  /// only includes properties with non-null values. This set is used to
  /// compute the intersection of common properties when [Inspector.objects]
  /// contains multiple objects.
  Set<(String, Type)> getObjectPropertySet(Inspectable obj) {
    Set<(String, Type)> toReturn = {};

    for (var property in obj.properties) {
      dynamic t = property.getValue(obj);
      toReturn.add((property.name, t.runtimeType));
    }

    return toReturn;
  }

  /// Builds the inspector table.
  ///
  /// Computes the intersection of properties across all [Inspector.objects],
  /// then renders one [TableRow] per common property. The [keys] cache is
  /// cleared whenever the objects list changes so editors are recreated with
  /// fresh state.
  @override
  Widget build(BuildContext context) {
    List<TableRow> fields = [];
    Set<(String, Type)> commonProperties = {};
    List<Inspectable> owners = [];

    if (!ListEquality().equals(widget.objects, objects)) {
      keys.clear();
    }
    objects = widget.objects;

    for (var obj in widget.objects) {
      var properties = getObjectPropertySet(obj);
      if (commonProperties.isEmpty) {
        commonProperties = properties;
        owners = [obj];
      } else {
        commonProperties = commonProperties.intersection(properties);
        owners.add(obj);
      }
    }

    for (var property in commonProperties) {
      fields.add(populateProperty(owners, property.$1, 1));
    }

    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade500),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
        children: fields,
      ),
    );
  }
}
