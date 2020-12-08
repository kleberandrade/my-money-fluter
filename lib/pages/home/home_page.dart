import 'package:flutter/material.dart';
import 'package:my_money/models/transaction_model.dart';
import 'package:my_money/pages/home/widgets/transaction_card.dart';
import 'package:my_money/pages/transaction/transaction_editor_page.dart';

import '../../controllers/home/home_controller.dart';
import 'widgets/balance_container.dart';
import 'widgets/balance_line_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    await _controller.fetch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildApp(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  _buildFab() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.pushNamed(context, '/transaction');
        await _controller.fetch();
        setState(() {});
      },
    );
  }

  _buildApp() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.0,
      centerTitle: true,
      title: Text(
        'Novembro',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  _buildBody() {
    return Column(
      children: [
        BalanceContainer(
          gains: _controller.totalGains,
          losses: _controller.totalLossses,
        ),
        BalanceLineChart(
          maxX: DateTime.now().day.toDouble(),
          maxY: _controller.maxValue ?? 0,
          spots: _controller.spots,
        ),
        _buildTransactionList(),
      ],
    );
  }

  _buildTransactionList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Transações',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _controller.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final transaction = _controller.transactions[index];
                return TransactionCard(
                  transaction: transaction,
                  onUpdate: _onUpdate,
                  onDelete: _onDelete,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
        ],
      ),
    );
  }

  _onUpdate(TransactionModel transaction) {
    //Navigator.pushNamed(context, '/category/editor', arguments: category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionEditorPage(transaction: transaction),
      ),
    );
  }

  _onDelete(TransactionModel transaction) {
    final index = _controller.transactions.indexOf(transaction);
    //_controller.delete(index);
    setState(() {});
  }
}
