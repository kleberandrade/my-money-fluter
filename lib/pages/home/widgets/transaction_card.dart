import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_money/helpers/date_helper.dart';
import 'package:my_money/helpers/money_helper.dart';
import 'package:my_money/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Function(TransactionModel) onUpdate;
  final Function(TransactionModel) onDelete;

  TransactionCard({
    this.transaction,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildCard(),
      actions: _buildActions(),
    );
  }

  _buildActions() {
    return [
      IconSlideAction(
        caption: 'Editar',
        color: Colors.blue,
        icon: Icons.edit,
        onTap: () => onUpdate(transaction),
      ),
      IconSlideAction(
        caption: 'Excluir',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () => onDelete(transaction),
      ),
    ];
  }

  _buildCard() {
    return ListTile(
      title: Text(transaction.description),
      subtitle: Text(transaction.category.name),
      leading: CircleAvatar(
        backgroundColor: transaction.category.color.withOpacity(0.2),
        child: Icon(
          transaction.category.icon,
          color: transaction.category.color,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(DateHelper.format(transaction.date),
              style: TextStyle(fontSize: 10)),
          Text(
            MoneyHelper.parse(transaction.value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.type == TransactionType.gains
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
