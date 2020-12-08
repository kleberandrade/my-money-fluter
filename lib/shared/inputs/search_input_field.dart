import 'package:flutter/material.dart';

class SearchInputField extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final EdgeInsets padding;

  const SearchInputField({
    Key key,
    this.hintText = 'Pesquisar ...',
    this.padding = const EdgeInsets.all(20.0),
    this.onChanged,
  }) : super(key: key);

  @override
  _SearchInputFieldState createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          hintText: widget.hintText,
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
