import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final EdgeInsets padding;

  const PrimaryButton({
    Key key,
    this.label,
    this.onPressed,
    this.padding = const EdgeInsets.only(top: 40.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: RaisedButton(
        padding: const EdgeInsets.all(20.0),
        child: Text(label.toUpperCase()),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
