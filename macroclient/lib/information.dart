import 'package:flutter/material.dart';
import 'package:macro_creator/structures.dart';

class Information extends StatefulWidget {
  final Global global;

  const Information(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateInformation();
}

class _StateInformation extends State<Information> {
  @override
  Widget build(BuildContext context) {
    return Text('Display Information');
  }
}
