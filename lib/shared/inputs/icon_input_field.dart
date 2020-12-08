import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class IconInputField extends StatefulWidget {
  final String label;
  final IconData initialValue;
  final Function(IconData) onSaved;
  final Function(String) validator;

  const IconInputField({
    Key key,
    this.onSaved,
    this.label,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  _IconInputFieldState createState() => _IconInputFieldState();
}

class _IconInputFieldState extends State<IconInputField> {
  final _controller = TextEditingController();
  IconData _selectedIcon;

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
      onSaved: (_) => widget.onSaved(_selectedIcon),
      validator: widget.validator,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        labelText: widget.label,
        suffixIcon: Icon(
          _selectedIcon != null ? _selectedIcon : Icons.keyboard_arrow_down,
        ),
      ),
      onTap: () => _openIconPicker(context),
    );
  }

  _openIconPicker(BuildContext context) async {
    IconData icon = await FlutterIconPicker.showIconPicker(
      context,
      adaptiveDialog: false,
      showTooltips: false,
      showSearchBar: true,
      iconPackMode: IconPack.material,
      iconPickerShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });

      _controller.text = _selectedIcon.toString();
    }
  }
}
