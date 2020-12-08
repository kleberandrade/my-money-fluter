import 'package:flutter/material.dart';
import 'package:my_money/models/category_model.dart';

import 'category_datasource.dart';

class CategoryMemoryDatasourceImpl implements CategoryDatasource {
  List<CategoryModel> _data = List<CategoryModel>();

  CategoryMemoryDatasourceImpl() {
    _data.add(CategoryModel(
      name: 'Alimentaçao',
      color: Colors.red,
      icon: Icons.food_bank,
    ));
  }

  @override
  Future<CategoryModel> create(CategoryModel category) {
    _data.add(category);
    return Future.value(category);
  }

  @override
  Future<CategoryModel> delete(int index) {
    final category = _data.removeAt(index);
    return Future.value(category);
  }

  @override
  Future<List<CategoryModel>> read() {
    return Future.value(_data);
  }

  @override
  Future<CategoryModel> update(int index, CategoryModel category) {
    _data[index] = category;
    return Future.value(category);
  }
}
