import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showFailureMessage(BuildContext context, {String message}) {
    Flushbar(
      message: message ?? '',
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.red,
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }

  static void showSuccessMessage(BuildContext context, {String message}) {
    Flushbar(
      message: message ?? '',
      icon: Icon(
        Icons.check_circle_outline,
        size: 28.0,
        color: Colors.green,
      ),
      duration: Duration(seconds: 3),
    )..show(context);
  }
}
