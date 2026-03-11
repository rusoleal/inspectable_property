import 'package:flutter/material.dart';
import '../inspectable.dart';

/// Base class for all property editors.
///
/// Subclasses override [getWidget] to return a type-specific editing widget
/// (e.g. a text field, checkbox, or slider). The default implementation
/// renders the property value as a read-only [Text] widget.
///
/// When multiple [owners] are provided, the base implementation compares
/// their values and shows an empty string when they differ — indicating a
/// mixed-value state.
///
/// To implement a custom editor, extend this class and override [getWidget]:
///
/// ```dart
/// class MyEditor extends EditorBase<MyType> {
///   MyEditor({super.key, required super.owners, required super.propertyName,
///              super.customData, super.onUpdatedProperty});
///
///   @override
///   Widget getWidget(BuildContext context) => MyEditorWidget(...);
/// }
/// ```
class EditorBase<T> {
  /// The [Inspectable] objects whose property is being edited.
  ///
  /// All owners are updated simultaneously when the user commits a change.
  final List<Inspectable> owners;

  /// The name of the property to edit.
  ///
  /// Used to look up the [InspectableProperty] on each owner via
  /// [Inspectable.getProperty].
  final String propertyName;

  /// Arbitrary data forwarded to [InspectableProperty.setValue] on each edit.
  ///
  /// Useful for passing context such as an undo stack or a transaction object.
  final Object? customData;

  /// Called after the property value has been successfully updated.
  ///
  /// Receives the new value so the parent widget can trigger a rebuild.
  final void Function(dynamic value)? onUpdatedProperty;

  /// Optional key applied to the widget returned by [getWidget].
  final Key? key;

  /// Creates an [EditorBase].
  ///
  /// [owners] and [propertyName] are required; all other parameters are
  /// optional.
  const EditorBase({
    this.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdatedProperty,
  });

  /// Returns the Flutter widget used to display and edit this property.
  ///
  /// The default implementation renders a [Text] with the current value of
  /// the property on the first owner, or an empty string when:
  /// - no owners are present,
  /// - the property is not found, or
  /// - values differ across multiple owners (mixed-value state).
  ///
  /// Subclasses should override this to return an interactive editor widget.
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

  /// Identifier for this editor type.
  ///
  /// Override in subclasses to return a human-readable name (e.g. `'int'`).
  /// The base implementation returns an empty string.
  static String get name => '';
}
