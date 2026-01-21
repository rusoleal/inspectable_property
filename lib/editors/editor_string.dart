import 'package:flutter/material.dart';
import '../editor_base.dart';
import '../inspectable.dart';

class EditorString extends EditorBase<String> {
  EditorString({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  @override
  Widget getWidget(BuildContext context) {
    return EditorStringWidget(
      key: key,
      owners: owners,
      propertyName: propertyName,
      customData: customData,
      onUpdateProperty: onUpdatedProperty,
    );
  }
}

class EditorStringWidget extends StatefulWidget {
  final List<Inspectable> owners;
  final String propertyName;
  final Object? customData;
  final void Function(dynamic value)? onUpdateProperty;

  const EditorStringWidget({
    super.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdateProperty,
  });

  @override
  State<StatefulWidget> createState() {
    return EditorStringWidgetState();
  }
}

class EditorStringWidgetState extends State<EditorStringWidget> {
  late TextEditingController ted;
  List<DropdownMenuItem<String>>? _items;
  bool readOnlyProperty = false;
  bool nullableProperty = true;

  @override
  void initState() {
    super.initState();

    String? value = '';
    if (widget.owners.isNotEmpty) {
      var property = widget.owners[0].getProperty(widget.propertyName);
      if (property != null) {
        value = property.getValue(widget.owners[0]);
      }
      for (int a = 1; a < widget.owners.length; a++) {
        var obj = widget.owners[a];
        var property =
            obj.getProperty(widget.propertyName);
        if (property == null) {
          value = '';
        } else if (property.getValue(obj) != value) {
          value = '';
        }
      }
    }

    for (var owner in widget.owners) {
      var property = owner.getProperty(widget.propertyName);
      if (property != null && property.readOnly) {
        readOnlyProperty = true;
      }
      if (property != null && !property.nullable) {
        nullableProperty = false;
      }
    }

    ted = TextEditingController(text: value);
    //updateItems();
  }

  /*  void updateItems() {

    List<String> values = [];
    if (widget.property.values != null) {
      values = widget.property.values!();
    }

    if (values.isNotEmpty) {
      Set<String> v = {};
      for (var value in values) {
        v.add(value);
      }
      _items = v.toList().map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(growable: false);
      if (!v.contains(widget.property.getValue(widget.owner))) {
        if (widget.property.setValue != null) {
          widget.property.setValue!(widget.owner,v.first, widget.customData);
        }
      }
    } else {
      ted.text = widget.property.getValue(widget.owner);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    if (_items != null && _items!.isNotEmpty) {
      return Container();
      /*return DropdownButton<String>(
        isExpanded: true,
        isDense: true,
        value: widget.property.getValue(widget.owner),
        items: _items,
        onChanged: (value) {
          if (value != null && !widget.property.readOnly && widget.property.setValue != null) {
            widget.property.setValue!(widget.owner, value, widget.customData);
            setState(() {});
          }
        },
      );*/
    } else {
      return TextField(
        controller: ted,
        readOnly: readOnlyProperty,
        decoration: const InputDecoration.collapsed(hintText: ''),
        onChanged: (value) {
          String? finalValue = value;
          if (value.isEmpty && nullableProperty) {
            finalValue = null;
          }
          if (!readOnlyProperty) {
            for (var owner in widget.owners) {
              var property = owner.getProperty(widget.propertyName);
              if (property != null && property.setValue != null) {
                property.setValue!(owner, finalValue, null);
              }
            }
            if (widget.onUpdateProperty != null) {
              widget.onUpdateProperty!(finalValue);
            }
            if (mounted) {
              setState(() {});
            }
          }
        },
      );
    }
  }
}
