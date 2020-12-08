import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInputField extends StatelessWidget {
  final String label;
  final DateTime initialValue;
  final Function(DateTime) onSaved;
  final Function(DateTime) validator;

  const DateInputField({
    Key key,
    this.label,
    this.initialValue,
    this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      initialValue: initialValue,
      format: DateFormat("dd/MM/yyyy"),
      keyboardType: TextInputType.datetime,
      validator: validator,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: label,
      ),
      onShowPicker: (context, date) {
        return showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(3000),
          initialDate: date ?? DateTime.now(),
        );
      },
      onSaved: onSaved,
    );
  }
}
