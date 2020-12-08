import 'package:flutter/material.dart';

class SimpleInputField extends StatelessWidget {
  final Function(String) onSaved;
  final Function(String) validator;
  final String label;
  final String initialValue;

  const SimpleInputField({
    Key key,
    this.onSaved,
    this.validator,
    this.label,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.text,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: label,
      ),
    );
  }
}
