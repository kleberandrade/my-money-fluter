import 'package:dartz/dartz.dart';
import 'package:my_money/datasource/category/category_datasource.dart';
import 'package:my_money/errors/category_error.dart';
import 'package:my_money/models/category_model.dart';

class CategoryRepository {
  CategoryDatasource _datasource;

  CategoryRepository(this._datasource);

  Future<Either<CategoryError, CategoryModel>> create(
      CategoryModel category) async {
    try {
      final result = await _datasource.create(category);
      return Right(result);
    } on Exception catch (error) {
      return Left(CategoryRepositoryError(error.toString()));
    }
  }

  Future<Either<CategoryError, List<CategoryModel>>> read() async {
    try {
      final result = await _datasource.read();
      return Right(result);
    } on Exception catch (error) {
      return Left(CategoryRepositoryError(error.toString()));
    }
  }

  Future<Either<CategoryError, CategoryModel>> update(
      int index, CategoryModel category) async {
    try {
      final result = await _datasource.update(index, category);
      return Right(result);
    } on Exception catch (error) {
      return Left(CategoryRepositoryError(error.toString()));
    }
  }

  Future<Either<CategoryError, CategoryModel>> delete(int index) async {
    try {
      final result = await _datasource.delete(index);
      return Right(result);
    } on Exception catch (error) {
      return Left(CategoryRepositoryError(error.toString()));
    }
  }
}
