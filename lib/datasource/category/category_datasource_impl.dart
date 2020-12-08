import 'package:sembast/sembast.dart';

import '../../models/category_model.dart';
import '../../singletons/database_singleton.dart';
import 'category_datasource.dart';

class CategoryDatasourceImpl implements CategoryDatasource {
  final _store = intMapStoreFactory.store('Category');

  Future<Database> get _db async => await DatabaseSingleton.instance.database;

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    await _store.add(await _db, category.toMap());
    return category;
  }

  @override
  Future delete(int index) async {
    final finder = Finder(filter: Filter.byKey(index + 1));
    await _store.delete(await _db, finder: finder);
  }

  @override
  Future<List<CategoryModel>> read() async {
    final snapshot = await _store.find(await _db);
    return snapshot.map((item) => CategoryModel.fromMap(item.value)).toList();
  }

  @override
  Future update(int index, CategoryModel category) async {
    final finder = Finder(filter: Filter.byKey(index + 1));
    await _store.update(await _db, category.toMap(), finder: finder);
  }
}
