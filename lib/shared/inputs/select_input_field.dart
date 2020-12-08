import 'package:flutter/material.dart';

class SelectInputField extends StatefulWidget {
  final Function(String) onSaved;
  final Function(String) validator;
  final String label;
  final String initialValue;
  final Function onTap;

  const SelectInputField({
    Key key,
    this.onSaved,
    this.validator,
    this.label,
    this.initialValue,
    this.onTap,
  }) : super(key: key);

  @override
  _SelectInputFieldState createState() => _SelectInputFieldState();
}

class _SelectInputFieldState extends State<SelectInputField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void didUpdateWidget(covariant SelectInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.text,
      onSaved: widget.onSaved,
      validator: widget.validator,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: widget.label,
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
      readOnly: true,
      onTap: widget.onTap,
    );
  }
}
