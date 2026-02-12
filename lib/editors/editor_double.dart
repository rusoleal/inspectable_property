import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import '../editor_base.dart';
import '../inspectable.dart';

/// Editor for [double] properties. Delegates rendering to [EditorDoubleWidget].
class EditorDouble extends EditorBase<double> {
  EditorDouble({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  @override
  Widget getWidget(BuildContext context) {
    return EditorDoubleWidget(
      key: key,
      owners: owners,
      propertyName: propertyName,
      customData: customData,
      onUpdateProperty: onUpdatedProperty,
    );
  }
}

/// A widget for editing double properties.
///
/// Renders a [Slider] when the property has a [InspectableProperty.clamp]
/// range set, otherwise renders a [TextField] with double parsing.
/// When multiple owners have differing values the field starts empty.
class EditorDoubleWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is updated.
  final void Function(dynamic value)? onUpdateProperty;

  const EditorDoubleWidget({
    super.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdateProperty,
  });

  @override
  State<StatefulWidget> createState() {
    return EditorDoubleWidgetState();
  }
}

/// State for [EditorDoubleWidget].
class EditorDoubleWidgetState extends State<EditorDoubleWidget> {
  /// Controller for the double text field (used when no clamp is set).
  late TextEditingController ted;

  /// Whether the property is read-only (disables editing).
  bool readOnlyProperty = false;

  /// Whether the property accepts null values.
  bool isNullable = true;

  /// Optional (min, max) range. When set, a [Slider] is rendered instead of a text field.
  (double, double)? clamp;

  /// The current slider value, tracked locally for immediate feedback.
  double? initialValue = 0.0;

  @override
  void initState() {
    super.initState();

    double? value;
    if (widget.owners.isNotEmpty) {
      var property = widget.owners[0].getProperty(widget.propertyName);
      if (property != null) {
        value = property.getValue(widget.owners[0]);
        clamp = property.clamp as (double, double)?;
        initialValue = value ?? 0.0;
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
      }
      if (property != null && !property.nullable) {
        isNullable = false;
      }
    }

    if (widget.owners.length != 1) {
      clamp = null;
    }

    ted = TextEditingController(
      text: value != null ? sprintf('%g', [value]) : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (clamp != null) {
      double min = clamp!.$1;
      double max = clamp!.$2;
      //double value = initialValue;
      /*if (value < min) {
        value = min;
        widget.property.setValue!(widget.owner, value, widget.customData);
      }
      if (value > max) {
        value = max;
        widget.property.setValue!(widget.owner, value, widget.customData);
      }*/
      return Slider.adaptive(
        value: initialValue ?? 0.0,
        onChanged: (value) {
          var property = widget.owners[0].getProperty(widget.propertyName);
          property?.setValue!(widget.owners[0], value, widget.customData);
          initialValue = value;
          if (widget.onUpdateProperty != null) {
            widget.onUpdateProperty!(value);
          }
          if (mounted) {
            setState(() {});
          }
        },
        //label: '${widget.property.getValue(widget.owner)}',
        min: min,
        max: max,
      );
    } else {
      return TextField(
        controller: ted,
        readOnly: readOnlyProperty,
        decoration: InputDecoration(isDense: true),
        onChanged: (value) {
          if (!readOnlyProperty) {
            double? number = double.tryParse(value);
            if (number != null || isNullable) {
              for (var owner in widget.owners) {
                var property =
                    owner.getProperty(widget.propertyName)
                        as InspectableProperty<double>?;
                if (property != null && property.setValue != null) {
                  property.setValue!(owner, number, null);
                }
              }
              if (widget.onUpdateProperty != null) {
                widget.onUpdateProperty!(value);
              }
            }
          }
        },
      );
    }
  }
}
