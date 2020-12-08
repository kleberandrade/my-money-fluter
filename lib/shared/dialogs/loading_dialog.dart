import 'package:flutter/material.dart';

class LoadingDialog {
  static BuildContext _context;

  static Future show(
    BuildContext context, {
    String message = 'Salvando...',
  }) async {
    _context = context;
    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: ListTile(
              title: Text(message),
              leading: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  static void hide() async {
    Navigator.pop(_context);
  }
}
