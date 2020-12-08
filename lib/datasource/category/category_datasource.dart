import 'package:my_money/models/category_model.dart';

abstract class CategoryDatasource {
  Future<CategoryModel> create(CategoryModel category);
  Future<List<CategoryModel>> read();
  Future update(int index, CategoryModel category);
  Future delete(int index);
}
