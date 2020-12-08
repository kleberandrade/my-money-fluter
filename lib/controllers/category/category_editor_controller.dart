import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../datasource/category/category_datasource_impl.dart';
import '../../errors/category_error.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';

class CategoryEditorController {
  CategoryRepository _repository;

  CategoryEditorController() {
    final datasource = CategoryDatasourceImpl();
    _repository = CategoryRepository(datasource);
  }

  String name = '';

  void setName(String value) => name = value;

  IconData icon;

  void setIcon(IconData value) => icon = value;

  Color color;

  void setColor(Color value) => color = value;

  Future<Either<CategoryError, CategoryModel>> create() async {
    final category = CategoryModel(
      name: name,
      icon: icon,
      color: color,
    );

    print('[CONTROLLER] ${category.toMap()}');
    return await _repository.create(category);
  }
}
