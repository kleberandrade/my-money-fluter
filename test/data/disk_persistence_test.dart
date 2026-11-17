import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:my_money/data/ledger_repository.dart';

void main() {
  test('native file migrates and survives closing/reopening on disk', () async {
    final folder = await Directory.systemTemp.createTemp('money_migration_');
    final path = '${folder.path}/my_money.db';
    final store = intMapStoreFactory.store('Transaction');
    try {
      var db = await databaseFactoryIo.openDatabase(path);
      await store.record(42).put(db, {
        'description': 'Legado',
        'value': 1234.56,
        'date': DateTime(2021, 1, 2).millisecondsSinceEpoch,
        'type': 0,
        'category': null,
        'isPending': false,
      });
      await db.close();
      db = await openLedger(databaseFactoryIo, path);
      expect((await LedgerRepository(db).readEntries()).single.cents, 123456);
      await db.close();
      db = await openLedger(databaseFactoryIo, path);
      expect((await LedgerRepository(db).readEntries()).single.id, 42);
      expect(db.version, 2);
      await db.close();
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
