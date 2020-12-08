import 'package:dartz/dartz.dart';
import 'package:my_money/datasource/transaction/transaction_datasource_impl.dart';
import 'package:my_money/errors/transaction_error.dart';
import 'package:my_money/models/category_model.dart';
import 'package:my_money/models/transaction_model.dart';
import 'package:my_money/repositories/transaction_repository.dart';

class TransactionEditorController {
  TransactionRepository _repository;

  TransactionEditorController() {
    final datasource = TransactionDatasourceImpl();
    _repository = TransactionRepository(datasource);
  }

  TransactionType type = TransactionType.losses;

  void setType(TransactionType value) => type = value;

  double money = 0.0;

  void setMoney(double value) => money = value;

  String description = '';

  void setDescription(String value) => description = value;

  DateTime date = DateTime.now();

  void setDate(DateTime value) => date = value;

  CategoryModel category;

  void setCategory(CategoryModel value) => category = value;

  bool isPending = false;

  void setIsPending(bool value) => isPending = value;

  Future<Either<TransactionError, TransactionModel>> create() async {
    final transaction = TransactionModel(
      type: type,
      category: category,
      date: date,
      description: description,
      isPending: isPending,
      value: money,
    );

    return await _repository.create(transaction);
  }
}
