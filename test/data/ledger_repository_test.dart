import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:my_money/data/ledger_repository.dart';
import 'package:my_money/domain/ledger.dart';

void main() {
  final categories = intMapStoreFactory.store('Category');
  final entries = intMapStoreFactory.store('Transaction');
  Map<String, Object?> legacy(num value) => {
    'description': 'Mercado',
    'value': value,
    'date': DateTime(2020, 11, 10).millisecondsSinceEpoch,
    'type': 1,
    'isPending': true,
    'category': {'name': 'Alimentação', 'icon': 58732, 'color': 4294198070},
  };
  test(
    'migrates actual legacy file shape, preserving keys, snapshots and unknown fields; reopens idempotently',
    () async {
      final factory = newDatabaseFactoryMemory();
      var db = await factory.openDatabase('legacy');
      await categories.record(9).put(db, {
        'name': 'Alimentação',
        'icon': 58732,
        'color': 4294198070,
      });
      await entries.record(4).put(db, {...legacy(0.1 + 0.2), 'custom': 'keep'});
      await db.close();
      db = await openLedger(factory, 'legacy');
      final repo = LedgerRepository(db);
      final entry = (await repo.readEntries()).single;
      expect(entry.id, 4);
      expect(entry.cents, 30);
      expect(entry.pending, true);
      expect(entry.category!.name, 'Alimentação');
      expect(entry.date, DateTime(2020, 11, 10));
      expect((await entries.record(4).get(db))!['custom'], 'keep');
      expect((await repo.readCategories()).single.id, 9);
      await db.close();
      db = await openLedger(factory, 'legacy');
      expect((await LedgerRepository(db).readEntries()).single.cents, 30);
      await db.close();
    },
  );
  test(
    'bad legacy value rolls back every converted record and schema version',
    () async {
      final factory = newDatabaseFactoryMemory();
      var db = await factory.openDatabase('broken');
      await entries.record(1).put(db, legacy(12.34));
      await entries.record(2).put(db, legacy(-5));
      await db.close();
      await expectLater(openLedger(factory, 'broken'), throwsFormatException);
      db = await factory.openDatabase('broken');
      expect(db.version, 1);
      expect(
        (await entries.record(1).get(db))!.containsKey('amountMinor'),
        false,
      );
      await db.close();
    },
  );
  test(
    'CRUD uses persistent keys after gaps; category snapshots survive deletion',
    () async {
      final db = await openLedger(newDatabaseFactoryMemory(), 'crud');
      final repo = LedgerRepository(db);
      final category = await repo.saveCategory(Category(name: 'Casa'));
      Entry item(String name) => Entry(
        description: name,
        cents: 123,
        date: DateTime(2026, 11, 17),
        kind: EntryKind.expense,
        category: category,
      );
      final first = await repo.saveEntry(item('Primeiro'));
      final second = await repo.saveEntry(item('Segundo'));
      await repo.deleteEntry(first.id!);
      await repo.saveEntry(
        Entry(
          id: second.id,
          description: 'Corrigido',
          cents: 234,
          date: second.date,
          kind: second.kind,
          category: category,
        ),
      );
      await repo.deleteCategory(category.id!);
      final found = (await repo.readEntries()).single;
      expect(found.id, second.id);
      expect(found.description, 'Corrigido');
      expect(found.cents, 234);
      expect(found.category!.name, 'Casa');
      await repo.deleteEntry(second.id!);
      expect(await repo.readEntries(), isEmpty);
      await db.close();
    },
  );
  test('demo is explicit, atomic and never overwrites nonempty data', () async {
    final db = await openLedger(newDatabaseFactoryMemory(), 'demo');
    final repo = LedgerRepository(db);
    await repo.loadDemo(DateTime(2026, 11));
    final count = (await repo.readEntries()).length;
    expect(count, greaterThan(3));
    await expectLater(repo.loadDemo(DateTime(2026, 11)), throwsStateError);
    expect((await repo.readEntries()).length, count);
    await db.close();
  });
}
