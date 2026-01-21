import 'package:flutter/material.dart';
import '../editor_base.dart';
import '../inspectable.dart';

class EditorBool extends EditorBase<bool> {
  EditorBool({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  @override
  Widget getWidget(BuildContext context) {
    return EditorBoolWidget(
      key: key,
      owners: owners,
      propertyName: propertyName,
      customData: customData,
      onUpdateProperty: onUpdatedProperty,
    );
  }
}

class EditorBoolWidget extends StatefulWidget {
  final List<Inspectable> owners;
  final String propertyName;
  final Object? customData;
  final void Function(dynamic value)? onUpdateProperty;

  const EditorBoolWidget({
    super.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdateProperty,
  });

  @override
  State<StatefulWidget> createState() {
    return EditorBoolWidgetState();
  }
}

class EditorBoolWidgetState extends State<EditorBoolWidget> {
  bool readOnlyProperty = false;
  bool? value;
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

    if (widget.owners.isNotEmpty) {
      var property = widget.owners[0].getProperty(widget.propertyName);
      if (property != null) {
        value = property.getValue(widget.owners[0]);
      }
      for (int a = 1; a < widget.owners.length; a++) {
        var obj = widget.owners[a];
        var property = obj.getProperty(widget.propertyName);
        if (property == null) {
          value = null;
        } else if (property.getValue(obj) != value) {
          value = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
      //visualDensity: VisualDensity.standard,
      value: value,
      tristate: nullable,
      onChanged: (bool? value) {
        if (!readOnlyProperty) {
          if (value != null || nullable) {
            for (var owner in widget.owners) {
              var property =
                  owner.getProperty(widget.propertyName)
                      as InspectableProperty<bool>?;
              if (property != null && property.setValue != null) {
                property.setValue!(owner, value!, null);
                this.value = value;
                if (widget.onUpdateProperty != null) {
                  widget.onUpdateProperty!(value);
                }
                if (mounted) {
                  setState(() {});
                }
              }
            }
          }
        }
      },
    );
  }
}
