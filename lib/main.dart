import 'package:flutter/material.dart';

import 'pages/category/category_editor_page.dart';
import 'pages/category/category_page.dart';
import 'pages/home/home_page.dart';
import 'pages/transaction/transaction_editor_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Money',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/transaction': (context) => TransactionEditorPage(),
        '/category': (context) => CategoryPage(),
        '/category/editor': (context) => CategoryEditorPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
