import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/datasource/category/category_memory_datasource_impl.dart';
import 'package:my_money/models/category_model.dart';
import 'package:my_money/repositories/category_repository.dart';

void main() {
  final _datasource = CategoryMemoryDatasourceImpl();
  final _repository = CategoryRepository(_datasource);

  test("Create a category", () async {
    final category = CategoryModel(
      name: 'Transporte',
      color: Colors.red,
      icon: Icons.car_repair,
    );

    final result = await _repository.create(category);
    expect(result | null, isA<CategoryModel>());
  });

  test("Update a category by index 0", () async {
    final category = CategoryModel(
      name: 'Transporte',
      color: Colors.blue,
      icon: Icons.car_repair,
    );

    final result = await _repository.update(0, category);
    expect(result | null, isA<CategoryModel>());
  });

  test("List all categories (total = 1)", () async {
    final result = await _repository.read();
    expect(result | null, isA<List<CategoryModel>>());
  });

  test("Delete categorie with index 0", () async {
    final result = await _repository.delete(0);
    expect(result | null, isA<CategoryModel>());
  });
}
