import 'package:flutter/material.dart';
import 'package:inspectable_property/inspector.dart';
import 'package:inspectable_property_example/inspectable_object.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspectable property Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  InspectableObject io = InspectableObject();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('InspectableObject {\n${io.toString()}\n}'),
            ),
            Expanded(child: Column(
              children: [
                Text('Object inspector'),
                Expanded(child: Inspector(
                  objects: [io],
                  onUpdatedProperty: (properties, value) {
                    setState(() {});
                  },
                )),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
