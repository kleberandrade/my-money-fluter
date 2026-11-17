import 'package:sembast/sembast.dart';
import '../domain/ledger.dart';

final _categories = intMapStoreFactory.store('Category');
final _entries = intMapStoreFactory.store('Transaction');

/// Sembast wraps onVersionChanged atomically. Throwing leaves version/data intact.
Future<Database> openLedger(
  DatabaseFactory factory,
  String path,
) => factory.openDatabase(
  path,
  version: 2,
  onVersionChanged: (db, old, version) async {
    if (old >= 2) return;
    for (final record in await _entries.find(db)) {
      final map = Map<String, Object?>.from(record.value);
      if (!map.containsKey('amountMinor')) {
        final value = map['value'];
        if (value is! num ||
            !value.isFinite ||
            value <= 0 ||
            value > Money.maxCents / 100) {
          throw FormatException(
            'Valor legado inválido no registro ${record.key}',
          );
        }
        // Original UI accepted two decimals. Round binary float residue once.
        map['amountMinor'] = (value * 100).round();
      }
      map.putIfAbsent(
        'dateLocal',
        () => dateKey(DateTime.fromMillisecondsSinceEpoch(map['date'] as int)),
      );
      Entry.fromMap(
        map,
        id: record.key,
      ); // Validate before committing any changes.
      await _entries.record(record.key).put(db, map);
    }
  },
);

class LedgerRepository {
  final Database db;
  LedgerRepository(this.db);
  Future<List<Category>> readCategories() async => (await _categories.find(
    db,
    finder: Finder(sortOrders: [SortOrder('name')]),
  )).map((r) => Category.fromMap(r.value, id: r.key)).toList();
  Future<List<Entry>> readEntries() async => (await _entries.find(
    db,
    finder: Finder(
      sortOrders: [SortOrder('dateLocal', false), SortOrder(Field.key, false)],
    ),
  )).map((r) => Entry.fromMap(r.value, id: r.key)).toList();
  Future<Category> saveCategory(Category category) async {
    final id = await _save(_categories, category.id, category.toMap());
    return Category.fromMap(category.toMap(), id: id);
  }

  Future<Entry> saveEntry(Entry entry) async {
    final id = await _save(_entries, entry.id, entry.toMap());
    return Entry.fromMap(entry.toMap(), id: id);
  }

  Future<int> _save(
    StoreRef<int, Map<String, Object?>> store,
    int? id,
    Map<String, Object?> value,
  ) async {
    if (id == null) return store.add(db, value);
    await db.transaction((txn) async {
      if (!await store.record(id).exists(txn)) {
        throw StateError('Registro não encontrado');
      }
      await store.record(id).update(txn, value);
    });
    return id;
  }

  Future<void> deleteEntry(int id) async {
    await _entries.record(id).delete(db);
  }

  Future<void> deleteCategory(int id) async {
    await _categories.record(id).delete(db);
  }

  Future<void> loadDemo(DateTime month) => db.transaction((txn) async {
    if (await _entries.count(txn) != 0 || await _categories.count(txn) != 0) {
      throw StateError('Os exemplos só podem ser carregados em uma base vazia');
    }
    final food = Category(name: 'Alimentação', icon: 0xe532, color: 0xffb56b3f);
    final home = Category(name: 'Casa', icon: 0xe318, color: 0xff5778a0);
    final work = Category(name: 'Trabalho', icon: 0xe8f9, color: 0xff38695e);
    final leisure = Category(name: 'Lazer', icon: 0xe40f, color: 0xff8c6bb1);
    for (final c in [food, home, work, leisure]) {
      await _categories.add(txn, c.toMap());
    }
    for (final e in [
      Entry(
        description: 'Salário',
        cents: 650000,
        date: DateTime(month.year, month.month, 1),
        kind: EntryKind.income,
        category: work,
      ),
      Entry(
        description: 'Aluguel',
        cents: 185000,
        date: DateTime(month.year, month.month, 5),
        kind: EntryKind.expense,
        category: home,
      ),
      Entry(
        description: 'Mercado da semana',
        cents: 32890,
        date: DateTime(month.year, month.month, 8),
        kind: EntryKind.expense,
        category: food,
      ),
      Entry(
        description: 'Café com amigos',
        cents: 4850,
        date: DateTime(month.year, month.month, 12),
        kind: EntryKind.expense,
        category: leisure,
      ),
      Entry(
        description: 'Projeto freelance',
        cents: 120000,
        date: DateTime(month.year, month.month, 15),
        kind: EntryKind.income,
        category: work,
      ),
      Entry(
        description: 'Internet',
        cents: 11990,
        date: DateTime(month.year, month.month, 20),
        kind: EntryKind.expense,
        category: home,
        pending: true,
      ),
    ]) {
      await _entries.add(txn, e.toMap());
    }
  });
}
