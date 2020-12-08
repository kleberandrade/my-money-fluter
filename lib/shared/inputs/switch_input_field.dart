import 'package:flutter/material.dart';

class SwitchInputField extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const SwitchInputField({
    this.label,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.04),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
