# inspectable_property

[![pub package](https://img.shields.io/pub/v/inspectable_property.svg)](https://pub.dev/packages/inspectable_property)
[![pub points](https://img.shields.io/pub/points/inspectable_property)](https://pub.dev/packages/inspectable_property/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter package that brings **reflection-like runtime inspection** to your Dart classes. Mix in `Inspectable`, describe your fields with `InspectableProperty`, and drop in the `Inspector` widget to get an instant, fully editable property panel — no code generation required.

---

## Features

- **`Inspectable` mixin** — expose any class's fields as a typed `properties` list at runtime.
- **`Inspector` widget** — a ready-made property editor that renders type-aware input controls in a clean table layout.
- **Built-in editors** for `int`, `double`, `bool`, `String`, and `Enum` — works out of the box.
- **Slider support** — `double` properties render as a `Slider` when a `clamp` range is provided.
- **Multi-object editing** — pass multiple `Inspectable` objects; common properties are shown and edits apply to all of them simultaneously.
- **Custom editors** — register your own editor widget per type or per individual property.
- **Rich metadata** — `readOnly`, `nullable`, `clamp`, `values`, `customEditor`, and sub-property nesting.

---

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  inspectable_property: ^0.0.3
```

Then fetch dependencies:

```sh
flutter pub get
```

---

## Usage

### 1. Make a class inspectable

Mix in `Inspectable` and register `InspectableProperty` descriptors:

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
        setValue: (obj, value, _) => health = value,
      ),
      InspectableProperty<double>(
        name: 'speed',
        getValue: (obj) => speed,
        setValue: (obj, value, _) => speed = value,
        clamp: (0.0, 10.0), // renders as a Slider
      ),
      InspectableProperty<bool>(
        name: 'alive',
        getValue: (obj) => alive,
        setValue: (obj, value, _) => alive = value,
      ),
      InspectableProperty<String>(
        name: 'name',
        getValue: (obj) => name,
        setValue: (obj, value, _) => name = value,
      ),
      InspectableProperty<Enum>(
        name: 'color',
        getValue: (obj) => color,
        setValue: (obj, value, _) => color = value as Color,
        values: () => Color.values,
      ),
    ]);
  }
}
```

### 2. Show the Inspector widget

```dart
import 'package:inspectable_property/inspector.dart';

final enemy = Enemy();

Inspector(
  objects: [enemy],
  onUpdatedProperty: (properties, value) {
    setState(() {}); // rebuild after edits
  },
)
```

### 3. Edit multiple objects at once

Pass a list of objects to edit them simultaneously. The inspector shows only the properties they share; fields with differing values appear blank until edited.

```dart
Inspector(
  objects: [enemy1, enemy2, enemy3],
  onUpdatedProperty: (properties, value) => setState(() {}),
)
```

### 4. Register a custom editor (optional)

Supply your own editor widget for any type via the `editors` map:

```dart
Inspector(
  objects: [enemy],
  editors: {
    MyCustomType: ({key, required owners, required propertyName, customData, onUpdatedProperty}) =>
        MyCustomEditor(key: key, owners: owners, propertyName: propertyName),
  },
)
```

---

## Built-in editors

| Type     | Widget            | Notes                                  |
|----------|-------------------|----------------------------------------|
| `int`    | `TextField`       | Integer validation                     |
| `double` | `TextField` / `Slider` | Slider when `clamp` is provided   |
| `bool`   | `Checkbox`        | Tristate when `nullable: true`         |
| `String` | `TextField`       | —                                      |
| `Enum`   | `DropdownButton`  | Requires `values` callback on property |

---

## InspectableProperty options

| Parameter      | Type                     | Description                                              |
|----------------|--------------------------|----------------------------------------------------------|
| `name`         | `String`                 | Display name shown in the inspector table                |
| `getValue`     | `Function`               | Getter — called to read the current value                |
| `setValue`     | `Function`               | Setter — called when the user commits a change           |
| `readOnly`     | `bool`                   | Disables editing when `true`                             |
| `nullable`     | `bool`                   | Allows `null` values (checkbox renders tristate)         |
| `clamp`        | `(double, double)`       | Min/max range; doubles render as a slider                |
| `values`       | `Function`               | Provides the list of valid values (required for enums)   |
| `customEditor` | `EditorBuilder?`         | Per-property custom editor factory                       |
| `getSubProperties` | `Function?`          | Returns nested `InspectableProperty` list for sub-objects |

---

## Additional information

- **Repository:** [github.com/rusoleal/inspectable_property](https://github.com/rusoleal/inspectable_property)
- **Issues & feedback:** [github.com/rusoleal/inspectable_property/issues](https://github.com/rusoleal/inspectable_property/issues)
- Dart SDK `^3.10.4` · Flutter `>=1.17.0`
