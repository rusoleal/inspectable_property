import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inspectable_property/editors/editor_bool.dart';
import 'package:inspectable_property/editors/editor_double.dart';
import 'package:inspectable_property/editors/editor_int.dart';
import 'editor_base.dart';
import 'editors/editor_string.dart';
import 'inspectable.dart';

typedef EditorBuilder =
    EditorBase Function({
      Key? key,
      required List<Inspectable> owners,
      required String propertyName,
      Object? customData,
      void Function(dynamic value)? onUpdatedProperty,
    });

class Inspector extends StatefulWidget {
  final Map<Type, EditorBuilder> editors;
  final List<Inspectable> objects;
  final Object? customData;
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

class InspectorState extends State<Inspector> {
  late List<Inspectable> objects;
  final Map<String, Key> keys = {};
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
      });
  }

  void propertyUpdated(dynamic value) {
    if (widget.onUpdatedProperty != null) {
      widget.onUpdatedProperty!([], value);
    }
  }

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
    final editorBuilder = editors[type];
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
