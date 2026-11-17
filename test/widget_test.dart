import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:my_money/data/ledger_repository.dart';
import 'package:my_money/ui/app.dart';
import 'package:my_money/domain/ledger.dart';

void main() {
  testWidgets(
    'empty state, demo, search, invalid form and save work together',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = (await tester.runAsync(
        () => openLedger(newDatabaseFactoryMemory(), 'widget'),
      ))!;
      addTearDown(() => tester.runAsync(db.close));
      await tester.pumpWidget(MoneyApp(repository: LedgerRepository(db)));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Seu dinheiro, com clareza.'), findsOneWidget);
      await tester.tap(find.text('Experimentar com exemplos'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Mercado da semana'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('search')), 'café');
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Mercado da semana'), findsNothing);
      expect(find.text('Café com amigos'), findsOneWidget);
      await tester.tap(find.text('Novo lançamento'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      await tester.tap(find.text('Salvar lançamento'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(find.text('Use de 1 a 100 caracteres'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('description')), 'Livro');
      await tester.enterText(find.byKey(const Key('amount')), '29,90');
      await tester.tap(find.text('Salvar lançamento'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(
        (await tester.runAsync(
          () => LedgerRepository(db).readEntries(),
        ))!.any((e) => e.description == 'Livro' && e.cents == 2990),
        true,
      );
    },
  );
  testWidgets('narrow screen and large type remain usable', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = (await tester.runAsync(
      () => openLedger(newDatabaseFactoryMemory(), 'mobile'),
    ))!;
    addTearDown(() => tester.runAsync(db.close));
    await tester.runAsync(() async {
      final repo = LedgerRepository(db);
      await repo.loadDemo(DateTime.now());
      await repo.saveEntry(
        Entry(
          description: 'Despesa com valor alto',
          cents: Money.maxCents,
          date: DateTime.now(),
          kind: EntryKind.expense,
        ),
      );
    });
    await tester.pumpWidget(MoneyApp(repository: LedgerRepository(db)));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    await tester.tap(find.text('Novo lançamento'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    expect(find.byKey(const Key('amount')), findsOneWidget);
  });
  testWidgets(
    'categories can be created, edited and deleted with confirmation',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = (await tester.runAsync(
        () => openLedger(newDatabaseFactoryMemory(), 'categories_ui'),
      ))!;
      addTearDown(() => tester.runAsync(db.close));
      await tester.pumpWidget(MoneyApp(repository: LedgerRepository(db)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categorias'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nova categoria'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Verde floresta'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Livros');
      await tester.tap(find.text('Salvar categoria'));
      await tester.pumpAndSettle();
      expect(find.text('Livros'), findsOneWidget);
      await tester.tap(find.text('Livros'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Estudos');
      await tester.tap(find.text('Salvar categoria'));
      await tester.pumpAndSettle();
      expect(find.text('Livros'), findsNothing);
      expect(find.text('Estudos'), findsOneWidget);
      await tester.tap(find.byTooltip('Ações de Estudos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir registro?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Estudos'), findsOneWidget);
      await tester.tap(find.byTooltip('Ações de Estudos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
      expect(find.text('Estudos'), findsNothing);
      expect(
        (await tester.runAsync(() => LedgerRepository(db).readCategories()))!,
        isEmpty,
      );
    },
  );
}
