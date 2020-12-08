import 'category_model.dart';

enum TransactionType { gains, losses }

class TransactionModel {
  String description;
  double value;
  DateTime date;
  bool isPending;
  CategoryModel category;
  TransactionType type;

  TransactionModel({
    this.description,
    this.value,
    this.date,
    this.isPending,
    this.category,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'value': value,
      'date': date?.millisecondsSinceEpoch,
      'isPending': isPending,
      'category': category?.toMap(),
      'type': type.index,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return TransactionModel(
      description: map['description'],
      value: map['value'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isPending: map['isPending'],
      category: CategoryModel.fromMap(map['category']),
      type: TransactionType.values[map['type']],
    );
  }
}
