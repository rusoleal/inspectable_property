import 'package:flutter/material.dart';
import '../editor_base.dart';
import '../inspectable.dart';

/// [EditorBase] implementation for [bool] properties.
///
/// Delegates the actual widget to [EditorBoolWidget].
class EditorBool extends EditorBase<bool> {
  /// Creates an [EditorBool].
  EditorBool({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  /// Returns an [EditorBoolWidget] configured with this editor's parameters.
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
/// Renders an adaptive checkbox that applies the new value to all [owners]
/// when tapped. Two special modes are activated by property metadata:
///
/// - **Tristate** — enabled when [InspectableProperty.nullable] is `true`.
///   The checkbox cycles through `true → false → null`.
/// - **Mixed-value** — when multiple owners hold differing values the checkbox
///   starts in the indeterminate (`null`) state.
class EditorBoolWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is successfully updated.
  final void Function(dynamic value)? onUpdateProperty;

  /// Creates an [EditorBoolWidget].
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
  /// Whether any owner has marked this property as read-only.
  bool readOnlyProperty = false;

  /// The current checkbox state.
  ///
  /// `null` represents the indeterminate state, shown when [nullable] is
  /// `true` or when owners hold differing values.
  bool? value;

  /// Whether the property accepts `null` (enables tristate checkbox mode).
  bool nullable = false;

  /// Reads the initial value from owners and detects read-only / nullable flags.
  ///
  /// Sets [value] to `null` when owners disagree to indicate a mixed state.
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

  /// Builds an adaptive [Checkbox] with optional tristate support.
  ///
  /// Changes are applied to all owners simultaneously unless the property is
  /// read-only.
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
