import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import '../editor_base.dart';
import '../inspectable.dart';

/// [EditorBase] implementation for [double] properties.
///
/// Delegates the actual widget to [EditorDoubleWidget].
class EditorDouble extends EditorBase<double> {
  /// Creates an [EditorDouble].
  EditorDouble({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  /// Returns an [EditorDoubleWidget] configured with this editor's parameters.
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
/// Chooses its presentation based on the property's [InspectableProperty.clamp]
/// setting:
///
/// - **Slider** — rendered when a single owner has a `clamp` range set,
///   providing immediate visual feedback within the min/max bounds.
/// - **TextField** — rendered otherwise; parses input as a double on each
///   change and applies it to all owners. The slider mode is disabled when
///   multiple owners are selected to avoid ambiguity.
///
/// When multiple owners hold differing values the field starts empty.
class EditorDoubleWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is successfully updated.
  final void Function(dynamic value)? onUpdateProperty;

  /// Creates an [EditorDoubleWidget].
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
  /// Controller that drives the [TextField] when no clamp range is set.
  late TextEditingController ted;

  /// Whether any owner has marked this property as read-only.
  bool readOnlyProperty = false;

  /// Whether any owner allows null values for this property.
  bool isNullable = true;

  /// The (min, max) clamp range, or `null` when there is no range restriction.
  ///
  /// Set to `null` when multiple owners are selected, since the slider only
  /// makes sense for a single-object selection.
  (double, double)? clamp;

  /// Tracks the current slider value for immediate UI feedback.
  double? initialValue = 0.0;

  /// Reads the initial value and metadata (clamp, readOnly, nullable) from the
  /// owners. Disables slider mode when more than one owner is selected.
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

  /// Builds either a [Slider.adaptive] or a [TextField] depending on whether
  /// [clamp] is set.
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
