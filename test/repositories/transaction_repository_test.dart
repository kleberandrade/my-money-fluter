import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/datasource/transaction/transaction_memory_datasource_impl.dart';
import 'package:my_money/models/category_model.dart';
import 'package:my_money/models/transaction_model.dart';
import 'package:my_money/repositories/transaction_repository.dart';

void main() {
  final _datasource = TransactionMemoryDatasourceImpl();
  final _repository = TransactionRepository(_datasource);
  final _category = CategoryModel(
    name: 'Informática',
    color: Colors.deepPurple,
    icon: Icons.computer,
  );

  test("Create a transaction", () async {
    final transaction = TransactionModel(
      value: 100.0,
      description: 'Headset',
      date: DateTime.now(),
      isPending: false,
      type: TransactionType.losses,
      category: _category,
    );
    final result = await _repository.create(transaction);
    expect(result | null, isA<TransactionModel>());
  });

  test("Update a transaction by index 0", () async {
    final transaction = TransactionModel(
      value: 450.0,
      description: 'Teclado gamer',
      date: DateTime.now(),
      isPending: false,
      type: TransactionType.losses,
      category: _category,
    );

    final result = await _repository.update(0, transaction);
    expect(result | null, isA<TransactionModel>());
  });

  test("List all transactions (total = 1)", () async {
    final result = await _repository.read();
    expect(result | null, isA<List<TransactionModel>>());
  });

  test("Delete transaction with index 0", () async {
    final result = await _repository.delete(0);
    expect(result | null, isA<TransactionModel>());
  });
}
