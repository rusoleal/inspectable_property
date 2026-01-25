import 'package:flutter/material.dart';
import 'package:inspectable_property/editor_base.dart';
import 'package:inspectable_property/inspectable.dart';

class EditorEnum extends EditorBase<Enum> {
  EditorEnum({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  @override
  Widget getWidget(BuildContext context) {
    return EditorEnumWidget(
      key: key,
      owners: owners,
      propertyName: propertyName,
      customData: customData,
      onUpdateProperty: onUpdatedProperty,
    );
  }
}

class EditorEnumWidget extends StatefulWidget {
  final List<Inspectable> owners;
  final String propertyName;
  final Object? customData;
  final void Function(dynamic value)? onUpdateProperty;

  const EditorEnumWidget({
    super.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdateProperty,
  });

  @override
  State<StatefulWidget> createState() {
    return EditorEnumWidgetState();
  }
}

class EditorEnumWidgetState extends State<EditorEnumWidget> {
  bool readOnlyProperty = false;
  bool nullable = false;

  @override
  void initState() {
    super.initState();

    for (var owner in widget.owners) {
      var property = owner.getProperty(widget.propertyName);
      if (property != null && property.readOnly) {
        readOnlyProperty = true;
      }
      if (property != null && property.nullable) {
        nullable = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Enum? value;
    var property =
        widget.owners[0].getProperty(widget.propertyName)
            as InspectableProperty<Enum>?;
    var values = property!.values!();
    value = property.getValue(widget.owners[0]);

    var items = values
        .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
        .toList();
    if (nullable) {
      items.add(DropdownMenuItem(value: null, child: Text('')));
    }

    return DropdownButton(
      items: items,
      isDense: true,
      isExpanded: true,
      value: value,
      onChanged: (value) {
        if (!readOnlyProperty) {
          for (var owner in widget.owners) {
            var property =
                owner.getProperty(widget.propertyName)
                    as InspectableProperty<Enum>?;
            //if (property != null && property.setValue != null) {
            property!.setValue!(owner, value, widget.customData);
            //}
          }
          if (widget.onUpdateProperty != null) {
            widget.onUpdateProperty!(value);
          }
          if (mounted) {
            setState(() {});
          }
        }
      },
    );
  }
}
