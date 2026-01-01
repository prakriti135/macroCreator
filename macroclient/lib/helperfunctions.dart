import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:macro_creator/structures.dart';


showMessage(String message, bool error) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        message,
      ),
      backgroundColor: error ? Colors.redAccent : Colors.greenAccent,
    ),
  );
}