import 'dart:async';

import 'package:flixr/views/home.dart';
import 'package:flutter/material.dart';

StreamController<int> streamController = StreamController<int>();

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(streamController.stream),
  ));
}