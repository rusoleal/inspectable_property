import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspectable_property/editor_base.dart';
import 'test_helpers.dart';

void main() {
  group('EditorBase', () {
    testWidgets('single owner displays value as Text', (tester) async {
      final obj = TestClass();
      final editor = EditorBase(
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('empty owners displays empty text', (tester) async {
      final editor = EditorBase(
        owners: [],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('multi-owner same value displays value', (tester) async {
      // Use stringValue because EditorBase compares getValue() result
      // against a String variable, so only String properties match correctly.
      final obj1 = TestClass();
      final obj2 = TestClass();
      final editor = EditorBase(
        owners: [obj1, obj2],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('multi-owner different values displays empty', (tester) async {
      final obj1 = TestClass();
      final obj2 = TestClass();
      obj2.stringValue = 'different';
      final editor = EditorBase(
        owners: [obj1, obj2],
        propertyName: 'stringValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('key is propagated to widget', (tester) async {
      final key = GlobalKey();
      final obj = TestClass();
      final editor = EditorBase(
        key: key,
        owners: [obj],
        propertyName: 'intValue',
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(Builder(
          builder: (context) => editor.getWidget(context),
        )),
      );
      expect(find.byKey(key), findsOneWidget);
    });
  });
}
