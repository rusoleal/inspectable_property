import 'package:flutter/material.dart';
import '../editor_base.dart';
import '../inspectable.dart';

/// Editor for [bool] properties. Delegates rendering to [EditorBoolWidget].
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

/// A [Checkbox]-based widget for editing boolean properties.
///
/// Supports tristate mode when the property is marked as [InspectableProperty.nullable].
/// When multiple owners have differing values the checkbox shows an indeterminate state.
class EditorBoolWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is updated.
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

/// State for [EditorBoolWidget].
class EditorBoolWidgetState extends State<EditorBoolWidget> {
  /// Whether the property is read-only (disables editing).
  bool readOnlyProperty = false;

  /// The current checkbox value. `null` indicates an indeterminate state.
  bool? value;

  /// Whether the property accepts null values (enables tristate checkbox).
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
