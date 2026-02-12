import 'package:flutter/material.dart';
import '../inspectable.dart';

/// Base class for all property editors.
///
/// Subclasses override [getWidget] to provide a type-specific editing widget
/// (e.g. a text field, checkbox, or slider). The default implementation
/// renders the property value as a read-only [Text] widget.
///
/// When multiple [owners] are provided, the base implementation shows an
/// empty string if the values differ across objects.
class EditorBase<T> {
  /// The list of [Inspectable] objects that own the property being edited.
  final List<Inspectable> owners;

  /// The name of the property to edit, used to look up the
  /// [InspectableProperty] on each owner.
  final String propertyName;

  /// Optional data forwarded to [InspectableProperty.setValue] when the
  /// property value changes.
  final Object? customData;

  /// Callback invoked after the property value is updated.
  final void Function(dynamic value)? onUpdatedProperty;

  /// An optional key for the widget returned by [getWidget].
  final Key? key;

  const EditorBase({
    this.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdatedProperty,
  });

  /// Returns the Flutter widget used to display and edit this property.
  ///
  /// The default implementation renders a [Text] widget showing the property
  /// value, or an empty string when the values differ across [owners].
  Widget getWidget(BuildContext context) {
    String value = '';

    if (owners.isNotEmpty) {
      var owner = owners[0];
      var property = owner.getProperty(propertyName);
      if (property != null) {
        value = property.getValue(owner).toString();
      }

      for (int a = 1; a < owners.length; a++) {
        var owner = owners[a];
        var property = owner.getProperty(propertyName);
        if (property == null) {
          value = '';
        } else if (property.getValue(owner) != value) {
          value = '';
        }
      }
    }

    return Text(key: key, value);
  }

  /// The display name of this editor type.
  static String get name => '';
}
