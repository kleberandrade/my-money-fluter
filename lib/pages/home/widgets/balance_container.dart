import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:my_money/helpers/money_helper.dart';

class BalanceContainer extends StatelessWidget {
  final double gains;
  final double losses;

  const BalanceContainer({
    Key key,
    this.gains,
    this.losses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Column(
        children: [
          _buildBalance(),
          Row(
            children: [
              _buildGains(),
              _buildLosses(),
            ],
          ),
        ],
      ),
    );
  }

  _buildBalance() {
    return Container(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Saldo em conta',
            textAlign: TextAlign.center,
          ),
          Text(
            MoneyHelper.parse(gains - losses),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  _buildGains() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
            backgroundColor: Colors.green,
          ),
          title: Text('Receitas'),
          subtitle: AutoSizeText(
            MoneyHelper.parse(gains),
            minFontSize: 16,
            maxFontSize: 20,
            maxLines: 1,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  _buildLosses() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: ListTile(
          trailing: CircleAvatar(
            child: Icon(
              Icons.arrow_downward,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
          ),
          title: Text(
            'Despesas',
            textAlign: TextAlign.end,
          ),
          subtitle: AutoSizeText(
            MoneyHelper.parse(losses),
            textAlign: TextAlign.end,
            minFontSize: 16,
            maxFontSize: 20,
            maxLines: 1,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
