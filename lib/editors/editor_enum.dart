import 'package:flutter/material.dart';
import 'package:inspectable_property/editor_base.dart';
import 'package:inspectable_property/inspectable.dart';

/// Editor for [Enum] properties. Delegates rendering to [EditorEnumWidget].
///
/// The property must provide a [InspectableProperty.values] callback that
/// returns the list of enum variants.
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

/// A [DropdownButton]-based widget for editing enum properties.
///
/// Populates the dropdown from [InspectableProperty.values]. When the property
/// is nullable, an empty option is appended to the dropdown items.
class EditorEnumWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is updated.
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

/// State for [EditorEnumWidget].
class EditorEnumWidgetState extends State<EditorEnumWidget> {
  /// Whether the property is read-only (disables editing).
  bool readOnlyProperty = false;

  /// Whether the property accepts null values (adds an empty dropdown option).
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
