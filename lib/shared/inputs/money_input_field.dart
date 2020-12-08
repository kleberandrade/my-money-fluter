import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class MoneyInputField extends StatefulWidget {
  final Function(double) onSaved;
  final Function(double) validator;
  final String label;
  final double initialValue;

  const MoneyInputField({
    Key key,
    this.onSaved,
    this.validator,
    this.label,
    this.initialValue,
  }) : super(key: key);

  @override
  _MoneyInputFieldState createState() => _MoneyInputFieldState();
}

class _MoneyInputFieldState extends State<MoneyInputField> {
  final _controller = MoneyMaskedTextController();

  @override
  void initState() {
    super.initState();
    _controller.updateValue(widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      onSaved: (_) {
        widget.onSaved(_controller.numberValue ?? 0.0);
      },
      validator: (_) {
        return widget.validator(_controller.numberValue ?? 0.0);
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: widget.label,
      ),
    );
  }
}
