import 'package:flutter/material.dart';
import 'package:my_money/models/transaction_model.dart';

import 'custom_radio_button.dart';

class TransactionTypeButton extends StatelessWidget {
  final int initialValue;
  final Function(dynamic) onChanged;

  const TransactionTypeButton({
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.04),
      child: CustomRadioButton(
        buttonLables: ['Despesa', 'Receita'],
        buttonValues: [TransactionType.losses, TransactionType.gains],
        initialValue: initialValue,
        buttonColor: Theme.of(context).canvasColor,
        selectedColor: Theme.of(context).accentColor,
        elevation: 0,
        height: 42,
        radioButtonValue: onChanged,
      ),
    );
  }
}
