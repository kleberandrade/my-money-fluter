import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorInputField extends StatefulWidget {
  final String label;
  final Color initialValue;
  final Function(Color) onSaved;
  final Function(String) validator;

  const ColorInputField({
    Key key,
    this.onSaved,
    this.label,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  _ColorInputFieldState createState() => _ColorInputFieldState();
}

class _ColorInputFieldState extends State<ColorInputField> {
  final _controller = TextEditingController();
  Color _pickerColor = Colors.transparent;
  Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      onSaved: (_) => widget.onSaved(_selectedColor),
      validator: widget.validator,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: widget.label,
        suffixIcon: Icon(
          Icons.color_lens,
          color: _selectedColor ?? Colors.black26,
        ),
      ),
      onTap: () => _openColorPicker(context),
    );
  }

  _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Selecione uma cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _pickerColor,
            onColorChanged: _onColorChanged,
          ),
        ),
        actions: [
          FlatButton(
            child: Text('SALVAR'),
            onPressed: _onSaved,
          ),
        ],
      ),
    );
  }

  _onSaved() {
    setState(() {
      _selectedColor = _pickerColor;
    });

    var color = _selectedColor.toString();
    color = color.replaceAll("Color(", "").replaceAll(")", "");
    color = color.replaceAll("Materialprimary value: ", "");

    _controller.text = color;
    Navigator.of(context).pop();
  }

  _onColorChanged(Color color) {
    setState(() {
      _pickerColor = color;
    });
  }
}
