import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy(); // <-- Thêm dòng này
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}