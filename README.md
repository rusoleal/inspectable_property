# Inspectable Property

A Flutter package that adds reflection-like capabilities to your Dart classes. Mix in `Inspectable` to expose a `properties` list that describes your object's fields at runtime — then use the built-in `Inspector` widget to view and edit them visually.

## Features

- **Inspectable mixin** — Gives any class a `properties` list of `InspectableProperty` descriptors with getters, setters, and metadata.
- **Inspector widget** — A ready-to-use property editor that renders a table of type-aware editors for one or more objects.
- **Built-in editors** — `int`, `double`, `bool`, `String`, and `Enum` types work out of the box.
- **Multi-object editing** — Select multiple objects and the Inspector shows their common properties; differing values appear blank.
- **Extensible** — Register custom editors per type or per property via the `customEditor` field.
- **Property options** — Mark properties as `readOnly`, `nullable`, provide `clamp` ranges (doubles render as sliders), or supply a `values` list.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  inspectable_property: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Make a class inspectable

Mix in `Inspectable` and register properties in the constructor:

```dart
import 'package:inspectable_property/inspectable.dart';

enum Color { red, green, blue }

class Enemy with Inspectable {
  int health;
  double speed;
  bool alive;
  String name;
  Color color;

  Enemy({
    this.health = 100,
    this.speed = 1.0,
    this.alive = true,
    this.name = 'Goblin',
    this.color = Color.red,
  }) {
    properties.addAll([
      InspectableProperty<int>(
        name: 'health',
        getValue: (obj) => health,
        setValue: (obj, value, customData) => health = value,
      ),
      InspectableProperty<double>(
        name: 'speed',
        getValue: (obj) => speed,
        setValue: (obj, value, customData) => speed = value,
        clamp: (0.0, 10.0), // renders as a slider
      ),
      InspectableProperty<bool>(
        name: 'alive',
        getValue: (obj) => alive,
        setValue: (obj, value, customData) => alive = value,
      ),
      InspectableProperty<String>(
        name: 'name',
        getValue: (obj) => name,
        setValue: (obj, value, customData) => name = value,
      ),
      InspectableProperty<Enum>(
        name: 'color',
        getValue: (obj) => color,
        setValue: (obj, value, customData) => color = value,
        values: () => Color.values,
      ),
    ]);
  }
}
```

### 2. Display the Inspector widget

Drop the `Inspector` widget into your UI and pass it one or more inspectable objects:

```dart
import 'package:inspectable_property/inspector.dart';

final enemy = Enemy();

Inspector(
  objects: [enemy],
  onUpdatedProperty: (properties, value) {
    setState(() {});
  },
)
```

### 3. Register custom editors (optional)

Provide a custom editor for any type via the `editors` map:

```dart
Inspector(
  objects: [enemy],
  editors: {
    MyCustomType: ({key, required owners, required propertyName, customData, onUpdatedProperty}) =>
        MyCustomEditor(key: key, owners: owners, propertyName: propertyName),
  },
)
```

## Built-in Editors

| Type | Widget | Notes |
|------|--------|-------|
| `int` | `TextField` | Integer validation |
| `double` | `TextField` / `Slider` | Slider when `clamp` is provided |
| `bool` | `Checkbox` | Tristate when `nullable` is true |
| `String` | `TextField` | — |
| `Enum` | `DropdownButton` | Requires `values` to be set |

## Additional Information

- Repository: https://github.com/rusoleal/inspectable_property
- Dart SDK: ^3.10.4
- Flutter: >=1.17.0
