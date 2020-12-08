import 'package:my_money/models/transaction_model.dart';
import 'package:my_money/singletons/database_singleton.dart';
import 'package:sembast/sembast.dart';

import 'transaction_datasource.dart';

class TransactionDatasourceImpl implements TransactionDatasource {
  final _store = intMapStoreFactory.store('Transaction');

  Future<Database> get _db async => await DatabaseSingleton.instance.database;

  @override
  Future<TransactionModel> create(TransactionModel transaction) async {
    await _store.add(await _db, transaction.toMap());
    return transaction;
  }

  @override
  Future delete(int index) async {
    final finder = Finder(filter: Filter.byKey(index + 1));
    await _store.delete(await _db, finder: finder);
  }

  @override
  Future<List<TransactionModel>> read() async {
    final snapshot = await _store.find(await _db);
    return snapshot
        .map((item) => TransactionModel.fromMap(item.value))
        .toList();
  }

  @override
  Future update(int index, TransactionModel transaction) async {
    final finder = Finder(filter: Filter.byKey(index + 1));
    await _store.update(await _db, transaction.toMap(), finder: finder);
  }
}
