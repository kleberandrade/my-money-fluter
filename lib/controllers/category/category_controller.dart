import 'package:dartz/dartz.dart';

import '../../datasource/category/category_datasource_impl.dart';
import '../../errors/category_error.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';

class CategoryController {
  CategoryRepository _repository;

  List<CategoryModel> categoryList = List<CategoryModel>();
  List<CategoryModel> categoryFilteredList = List<CategoryModel>();

  int get length => categoryFilteredList.length;

  CategoryController() {
    final dataSource = CategoryDatasourceImpl();
    _repository = CategoryRepository(dataSource);
  }

  Future<Either<CategoryError, CategoryModel>> create(
      CategoryModel category) async {
    return await _repository.create(category);
  }

  Future<Either<CategoryError, CategoryModel>> update(
      int index, CategoryModel category) async {
    return await _repository.update(index, category);
  }

  Future<Either<CategoryError, List<CategoryModel>>> read() async {
    final result = await _repository.read();
    result.fold((l) => null, (r) {
      categoryList = r;
      categoryFilteredList = categoryList;
    });
    return result;
  }

  Future<Either<CategoryError, CategoryModel>> delete(int index) async {
    final result = await _repository.delete(index);
    result.fold((l) => null, (category) {
      categoryFilteredList.remove(category);
    });
    return result;
  }

  void search(String filter) {
    categoryFilteredList = categoryList
        .where((category) =>
            category.name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }
}
