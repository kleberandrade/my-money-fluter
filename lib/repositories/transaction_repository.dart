import 'package:dartz/dartz.dart';
import 'package:my_money/datasource/transaction/transaction_datasource.dart';
import 'package:my_money/errors/transaction_error.dart';
import 'package:my_money/models/transaction_model.dart';

class TransactionRepository {
  TransactionDatasource _datasource;

  TransactionRepository(this._datasource);

  Future<Either<TransactionError, TransactionModel>> create(
      TransactionModel transaction) async {
    try {
      final result = await _datasource.create(transaction);
      return Right(result);
    } on Exception catch (error) {
      return Left(TransactionRepositoryError(error.toString()));
    }
  }

  Future<Either<TransactionError, List<TransactionModel>>> read() async {
    try {
      final result = await _datasource.read();
      return Right(result);
    } on Exception catch (error) {
      return Left(TransactionRepositoryError(error.toString()));
    }
  }

  Future<Either<TransactionError, TransactionModel>> update(
      int index, TransactionModel transaction) async {
    try {
      final result = await _datasource.update(index, transaction);
      return Right(result);
    } on Exception catch (error) {
      return Left(TransactionRepositoryError(error.toString()));
    }
  }

  Future<Either<TransactionError, TransactionModel>> delete(int index) async {
    try {
      final result = await _datasource.delete(index);
      return Right(result);
    } on Exception catch (error) {
      return Left(TransactionRepositoryError(error.toString()));
    }
  }
}
