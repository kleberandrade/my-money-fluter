import 'package:my_money/datasource/transaction/transaction_datasource.dart';
import 'package:my_money/models/transaction_model.dart';

class TransactionMemoryDatasourceImpl implements TransactionDatasource {
  List<TransactionModel> _data = List<TransactionModel>();

  @override
  Future<TransactionModel> create(TransactionModel transaction) {
    _data.add(transaction);
    return Future.value(transaction);
  }

  @override
  Future<TransactionModel> delete(int index) {
    final transaction = _data.removeAt(index);
    return Future.value(transaction);
  }

  @override
  Future<List<TransactionModel>> read() {
    return Future.value(_data);
  }

  @override
  Future<TransactionModel> update(int index, TransactionModel transaction) {
    _data[index] = transaction;
    return Future.value(transaction);
  }
}
