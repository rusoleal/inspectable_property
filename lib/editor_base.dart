import 'package:flutter/material.dart';
import '../inspectable.dart';

class EditorBase<T> {
  final List<Inspectable> owners;
  final String propertyName;
  final Object? customData;
  final void Function(dynamic value)? onUpdatedProperty;
  final Key? key;

  const EditorBase({
    this.key,
    required this.owners,
    required this.propertyName,
    this.customData,
    this.onUpdatedProperty,
  });

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

  static String get name => '';
}
