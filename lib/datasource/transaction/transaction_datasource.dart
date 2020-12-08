import 'package:my_money/models/transaction_model.dart';

abstract class TransactionDatasource {
  Future<TransactionModel> create(TransactionModel transaction);
  Future<List<TransactionModel>> read();
  Future update(int index, TransactionModel transaction);
  Future delete(int index);
}
