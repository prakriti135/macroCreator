import 'package:flutter/material.dart';
import 'package:macro_creator/structures.dart';

class Inspect extends StatefulWidget {
  final Global global;

  const Inspect(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateInspect();
}

class _StateInspect extends State<Inspect> {
  @override
  Widget build(BuildContext context) {
    return Text('Inspect Macro');
  }
}
