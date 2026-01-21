import 'package:flutter/material.dart';
import '../editor_base.dart';
import '../inspectable.dart';

class EditorInt extends EditorBase<int> {
  EditorInt({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  @override
  Widget getWidget(BuildContext context) {
    return EditorIntWidget(
      key: key,
      owners: owners,
      propertyName: propertyName,
      customData: customData,
      onUpdateProperty: onUpdatedProperty,
    );
  }
}

class EditorIntWidget extends StatefulWidget {
  final List<Inspectable> owners;
  final String propertyName;
  final Object? customData;
  final void Function(dynamic value)? onUpdateProperty;

  const EditorIntWidget({
    super.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdateProperty,
  });

  @override
  State<StatefulWidget> createState() {
    return EditorIntWidgetState();
  }
}

class EditorIntWidgetState extends State<EditorIntWidget> {
  late TextEditingController ted;
  bool readOnlyProperty = false;

  @override
  void initState() {
    super.initState();

    int? value;
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

    for (var owner in widget.owners) {
      var property = owner.getProperty(widget.propertyName);
      if (property != null && property.readOnly) {
        readOnlyProperty = true;
        break;
      }
    }

    ted = TextEditingController(text: value != null ? value.toString() : '');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ted,
      decoration: InputDecoration(
        isDense: true
      ),
      onChanged: (value) {
        if (!readOnlyProperty) {
          int? integerValue = int.tryParse(value);

          if (integerValue != null) {
            for (var owner in widget.owners) {
              var property =
                  owner.getProperty(widget.propertyName)
                      as InspectableProperty<int>?;
              if (property != null && property.setValue != null) {
                property.setValue!(owner, integerValue, null);
              }
            }
            if (widget.onUpdateProperty != null) {
              widget.onUpdateProperty!(integerValue);
            }
            if (mounted) {
              setState(() {});
            }
          }
        }
      },
    );
  }
}
