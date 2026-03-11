import 'package:flutter/material.dart';
import 'package:inspectable_property/editor_base.dart';
import 'package:inspectable_property/inspectable.dart';

/// [EditorBase] implementation for [Enum] properties.
///
/// Delegates the actual widget to [EditorEnumWidget]. The property **must**
/// provide a [InspectableProperty.values] callback that returns the full list
/// of enum variants; omitting it will cause a runtime error.
class EditorEnum extends EditorBase<Enum> {
  /// Creates an [EditorEnum].
  EditorEnum({
    super.key,
    required super.owners,
    required super.propertyName,
    super.customData,
    super.onUpdatedProperty,
  });

  /// Returns an [EditorEnumWidget] configured with this editor's parameters.
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
/// Populates the dropdown from [InspectableProperty.values] and applies the
/// selected value to all [owners] on change. Two optional behaviours:
///
/// - **Nullable** — when [InspectableProperty.nullable] is `true`, an extra
///   empty item is appended so the user can select `null`.
/// - **Read-only** — the dropdown's `onChanged` callback is suppressed when
///   any owner marks the property as read-only.
class EditorEnumWidget extends StatefulWidget {
  /// The [Inspectable] objects that own this property.
  final List<Inspectable> owners;

  /// The name used to look up the [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue].
  final Object? customData;

  /// Called after the property value is successfully updated.
  final void Function(dynamic value)? onUpdateProperty;

  /// Creates an [EditorEnumWidget].
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
  /// Whether any owner has marked this property as read-only.
  bool readOnlyProperty = false;

  /// Whether the property accepts `null` as a valid enum value.
  ///
  /// When `true`, an extra empty [DropdownMenuItem] is added at the end of
  /// the dropdown list.
  bool nullable = false;

  /// Detects read-only and nullable flags across all owners.
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

  /// Builds an expanded [DropdownButton] whose items come from
  /// [InspectableProperty.values].
  ///
  /// The selected value is read from the first owner on every build, so the
  /// dropdown always reflects the current state. Changes are applied to all
  /// owners simultaneously.
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
