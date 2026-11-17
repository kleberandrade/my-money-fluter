import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/state/ledger_controller.dart';
import 'package:my_money/data/ledger_repository.dart';
import 'package:my_money/domain/ledger.dart';
import 'package:sembast/sembast_memory.dart';

class FailingRepository extends LedgerRepository {
  FailingRepository(super.db);
  @override
  Future<List<Entry>> readEntries() async =>
      throw StateError('disk unavailable');
}

void main() {
  test(
    'read failure exposes retryable error and always clears loading',
    () async {
      final db = await openLedger(newDatabaseFactoryMemory(), 'error');
      final controller = LedgerController(FailingRepository(db));
      await controller.refresh();
      expect(controller.busy, false);
      expect(controller.error, contains('Seus registros não foram apagados'));
      expect(controller.entries, isEmpty);
      controller.dispose();
      await db.close();
    },
  );
  test(
    'mutation failure preserves prior snapshot and refresh clears error',
    () async {
      final db = await openLedger(newDatabaseFactoryMemory(), 'state');
      final repo = LedgerRepository(db);
      final controller = LedgerController(repo);
      await controller.perform(() => repo.loadDemo(DateTime(2026, 11)));
      final count = controller.entries.length;
      await controller.perform(
        () async => throw const FormatException('Entrada inválida'),
      );
      expect(controller.error, 'Entrada inválida');
      expect(controller.entries.length, count);
      await controller.refresh();
      expect(controller.error, isNull);
      controller.month = DateTime(2026, 12);
      controller.moveMonth(1);
      expect(controller.month, DateTime(2027));
      controller.dispose();
      await db.close();
    },
  );
}
