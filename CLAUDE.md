# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter/Dart package (`inspectable_property`) that adds runtime reflection-like capabilities to Dart classes. Classes mix in `Inspectable` to expose a `properties` list, and the `Inspector` widget renders type-aware editors for viewing/editing those properties.

## Commands

- **Get dependencies:** `flutter pub get`
- **Run tests:** `flutter test`
- **Run single test:** `flutter test test/inspectable_property_test.dart`
- **Analyze:** `flutter analyze`
- **Run example app:** `cd example && flutter run`

## Architecture

### Core layer (`lib/`)

- **`inspectable.dart`** — Defines the `Inspectable` mixin (provides `properties` list, `getProperty()`, `removeProperty()`) and `InspectableProperty<T>` (generic property descriptor with getter/setter, metadata like `readOnly`, `nullable`, `clamp`, `values`, `customEditor`, and optional `getSubProperties`).
- **`editor_base.dart`** — `EditorBase<T>`, the base class for all property editors. Not a widget itself; has a `getWidget(BuildContext)` method that returns a Flutter widget. Handles multi-object value comparison (shows blank when values differ).
- **`inspector.dart`** — `Inspector` StatefulWidget that takes a list of `Inspectable` objects, computes their common properties (intersection), and renders a `Table` with one row per property. Maintains a `Map<Type, EditorBuilder>` with built-in editors for `int`, `double`, `bool`, `String`, `Enum`. User-supplied editors (via `editors` parameter) take precedence over built-ins.

### Editors (`lib/editors/`)

Each editor extends `EditorBase<T>` and provides a StatefulWidget:
- `editor_int.dart` — TextField with int parsing
- `editor_double.dart` — TextField or Slider (when `clamp` is set)
- `editor_bool.dart` — Checkbox (tristate when nullable)
- `editor_string.dart` — TextField
- `editor_enum.dart` — DropdownButton (requires `values` on the property)

### Key patterns

- **Multi-object editing:** When multiple `Inspectable` objects are passed to `Inspector`, only properties common to all objects are shown. If values differ across objects, the editor displays blank/empty. Edits apply to all selected objects.
- **Custom editors:** Registered via `EditorBuilder` typedef — a factory function that returns an `EditorBase`. Custom editors can be keyed by `Type` or selected per-property via `InspectableProperty.customEditor`.
- **Enum handling:** Enum properties must be typed as `InspectableProperty<Enum>` and provide a `values` callback. The inspector falls back to the `Enum` editor when the exact type isn't found in the editors map.
