import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const VendingApp());
}

class VendingApp extends StatelessWidget {
  const VendingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yu-Gi-Oh! Booster Machine',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      builder: (context, child) {
        return AppBackground(child: child!);
      },
      home: const HomePage(),
    );
  }
}
