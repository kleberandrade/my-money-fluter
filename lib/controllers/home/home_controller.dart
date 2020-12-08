import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:my_money/models/vector2.dart';

import '../../datasource/transaction/transaction_datasource_impl.dart';
import '../../errors/transaction_error.dart';
import '../../models/transaction_model.dart';
import '../../repositories/transaction_repository.dart';

class HomeController {
  TransactionRepository _repository;

  List<TransactionModel> transactions = List<TransactionModel>();
  int get length => transactions.length;

  double get totalGains => transactions
      .where((element) => element.type == TransactionType.gains)
      .fold(0.0, (previousValue, element) => previousValue + element.value);

  double get totalLossses => transactions
      .where((element) => element.type == TransactionType.losses)
      .fold(0.0, (previousValue, element) => previousValue + element.value);

  double get balance => totalGains - totalLossses;

  List<Vector2> spots = new List<Vector2>();

  double get maxValue =>
      spots.reduce((value, element) => value.y > element.y ? value : element).y;

  HomeController() {
    final datasource = TransactionDatasourceImpl();
    _repository = TransactionRepository(datasource);
  }

  Future<Either<TransactionError, List<TransactionModel>>> fetch() async {
    final result = await _repository.read();
    result.fold(
      (l) => null,
      (r) {
        this.transactions = r;
        this.spots = filterToSpot();
        print(spots);
      },
    );

    return result;
  }

  List<Vector2> filterToSpot() {
    final today = DateTime.now();
    final day = today.day;
    final month = today.month;

    final list = transactions
        .where((item) =>
            item.date.month == month &&
            item.type == TransactionType.losses &&
            item.date.day <= day)
        .toList();

    final map = Map<int, double>();
    for (var item in list) {
      if (map.containsKey(item.date.day)) {
        map[item.date.day] += item.value;
      } else {
        map[item.date.day] = item.value;
      }
    }

    final spots = List<Vector2>();
    map.forEach((key, value) {
      spots.add(Vector2(x: key.toDouble(), y: value));
    });

    return spots;
  }
}
