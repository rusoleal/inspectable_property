import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inspectable_property/editors/editor_bool.dart';
import 'package:inspectable_property/editors/editor_double.dart';
import 'package:inspectable_property/editors/editor_enum.dart';
import 'package:inspectable_property/editors/editor_int.dart';
import 'editor_base.dart';
import 'editors/editor_string.dart';
import 'inspectable.dart';

/// Factory function signature for creating property editors.
///
/// Used to register custom editors in the [Inspector] widget's `editors` map,
/// keyed by the property's [Type].
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
/// When multiple objects are provided, only properties common to all objects
/// are shown. Values that differ across objects appear blank in the editor.
///
/// Built-in editors are provided for [int], [double], [bool], [String], and
/// [Enum]. Additional editors can be supplied via the [editors] map; user-
/// supplied editors take precedence over built-ins.
class Inspector extends StatefulWidget {
  /// Map of property [Type] to [EditorBuilder] factory. User-supplied entries
  /// override the built-in editors.
  final Map<Type, EditorBuilder> editors;

  /// The list of [Inspectable] objects whose properties are displayed.
  final List<Inspectable> objects;

  /// Optional data forwarded to each editor and ultimately to
  /// [InspectableProperty.setValue].
  final Object? customData;

  /// Called whenever any property value is updated through the inspector.
  final void Function(List<InspectableProperty> properties, dynamic value)?
  onUpdatedProperty;

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
  /// Snapshot of the current objects list, used to detect changes across rebuilds.
  late List<Inspectable> objects;

  /// Cache of [GlobalKey]s keyed by property name, ensuring editors maintain
  /// state across rebuilds.
  final Map<String, Key> keys = {};

  /// Merged editor map (user-supplied + built-in defaults).
  late Map<Type, EditorBuilder> editors;

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

  /// Forwards property change notifications to the widget's [Inspector.onUpdatedProperty] callback.
  void propertyUpdated(dynamic value) {
    if (widget.onUpdatedProperty != null) {
      widget.onUpdatedProperty!([], value);
    }
  }

  /// Builds a [TableRow] for a single property, resolving the appropriate
  /// editor based on the property's type. The [level] parameter controls
  /// indentation for nested sub-properties.
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

  /// Returns a set of (name, runtimeType) pairs for all properties on [obj].
  /// Used to compute the intersection of common properties across multiple objects.
  Set<(String, Type)> getObjectPropertySet(Inspectable obj) {
    Set<(String, Type)> toReturn = {};

    for (var property in obj.properties) {
      dynamic t = property.getValue(obj);
      toReturn.add((property.name, t.runtimeType));
    }

    return toReturn;
  }

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
