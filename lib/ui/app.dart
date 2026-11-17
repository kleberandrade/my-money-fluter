import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import '../data/ledger_repository.dart';
import '../data/open_database.dart';
import '../domain/ledger.dart';
import '../state/ledger_controller.dart';
import 'editors.dart';
import 'insights.dart';
import 'theme.dart';
import 'category_visuals.dart';

class MoneyApp extends StatelessWidget {
  final LedgerRepository? repository;
  const MoneyApp({super.key, this.repository});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'My Money',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ink,
        primary: ink,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: canvas,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xffe3e8e1)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: repository == null
        ? const _Bootstrap()
        : LedgerScreen(repository: repository!),
  );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<LedgerRepository> future = openRepository();
  @override
  Widget build(BuildContext context) => FutureBuilder<LedgerRepository>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasData) return LedgerScreen(repository: snapshot.data!);
      return Scaffold(
        body: Center(
          child: snapshot.hasError
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Não foi possível abrir seus dados',
                        style: TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Se houver dados antigos, preserve uma cópia de my_money.db. Verifique o armazenamento local e tente novamente. Nenhum registro será apagado automaticamente.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () =>
                            setState(() => future = openRepository()),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      );
    },
  );
}

class LedgerScreen extends StatefulWidget {
  final LedgerRepository repository;
  const LedgerScreen({super.key, required this.repository});
  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  late final controller = LedgerController(widget.repository)..refresh();
  int page = 0;
  String query = '';
  String filter = 'Todos';
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> editEntry([Entry? entry]) async {
    final result = await showDialog<Entry>(
      context: context,
      builder: (_) =>
          EntryEditor(entry: entry, categories: controller.categories),
    );
    if (result != null) {
      await controller.perform(() async {
        await widget.repository.saveEntry(result);
      });
    }
  }

  Future<void> editCategory([Category? category]) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (_) => CategoryEditor(category: category),
    );
    if (result != null) {
      await controller.perform(() async {
        await widget.repository.saveCategory(result);
      });
    }
  }

  Future<void> delete(String label, Future<void> Function() action) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: Text(label),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (accepted == true) await controller.perform(action);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final wide = MediaQuery.sizeOf(context).width >= 1000;
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              if (wide) _rail(),
              Expanded(
                child: Column(
                  children: [
                    if (controller.busy)
                      const LinearProgressIndicator(minHeight: 3),
                    if (controller.error != null)
                      MaterialBanner(
                        content: Text(controller.error!),
                        actions: [
                          TextButton(
                            onPressed: controller.refresh,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(wide ? 36 : 20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _header(wide),
                                const SizedBox(height: 28),
                                if (page == 0)
                                  ..._overview(wide)
                                else
                                  ..._categories(),
                                const SizedBox(height: 32),
                                const Text(
                                  'SEUS DADOS FICAM COM VOCÊ  ·  Armazenamento local',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: page,
                onDestinationSelected: (i) => setState(() => page = i),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.space_dashboard_outlined),
                    label: 'Visão geral',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.category_outlined),
                    label: 'Categorias',
                  ),
                ],
              ),
      );
    },
  );
  Widget _rail() => Container(
    width: 220,
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: Color(0xffe3e8e1))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: ink, size: 32),
            SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'my money',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Mais clareza. Mais equilíbrio.',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 52),
        _nav(0, Icons.space_dashboard_outlined, 'Visão geral'),
        const SizedBox(height: 10),
        _nav(1, Icons.category_outlined, 'Categorias'),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: canvas,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: ink),
              SizedBox(height: 12),
              Text(
                'Simples e pessoal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text(
                'Sem conexão bancária.\nSem complicação.',
                style: TextStyle(color: muted, height: 1.6, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _nav(int index, IconData icon, String label) => TextButton.icon(
    style: TextButton.styleFrom(
      backgroundColor: page == index
          ? const Color(0xffe6eee8)
          : Colors.transparent,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(18),
    ),
    onPressed: () => setState(() => page = index),
    icon: Icon(icon),
    label: Text(label),
  );
  Widget _header(bool wide) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    runSpacing: 20,
    spacing: 24,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MY MONEY / FINANÇAS PESSOAIS',
            style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.8),
          ),
          const SizedBox(height: 10),
          Text(
            page == 0 ? 'Seu mês em equilíbrio.' : 'Tudo no seu lugar.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            page == 0
                ? 'Acompanhe o que entra, o que sai e o que fica.'
                : 'Organize seus lançamentos com categorias pessoais.',
            style: const TextStyle(color: muted),
          ),
        ],
      ),
      FilledButton.icon(
        onPressed: controller.busy
            ? null
            : () => page == 0 ? editEntry() : editCategory(),
        icon: const Icon(Icons.add, size: 20),
        label: Text(page == 0 ? 'Novo lançamento' : 'Nova categoria'),
      ),
    ],
  );
  List<Widget> _overview(bool wide) {
    final summary = controller.summary;
    final entries = summary.entries
        .where(
          (e) =>
              '${e.description} ${e.category?.name ?? ''}'
                  .toLowerCase()
                  .contains(query.toLowerCase()) &&
              (filter == 'Todos' ||
                  (filter == 'Pendentes'
                      ? e.pending
                      : e.kind ==
                            (filter == 'Receitas'
                                ? EntryKind.income
                                : EntryKind.expense))),
        )
        .toList();
    return [
      Row(
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: () => controller.moveMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy', 'pt_BR').format(controller.month),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: () => controller.moveMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              controller.moveMonth(
                (now.year - controller.month.year) * 12 +
                    now.month -
                    controller.month.month,
              );
            },
            child: const Text('Hoje'),
          ),
        ],
      ),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (context, c) {
          final cards = [
            BalanceCard(
              label: 'Saldo previsto',
              value: summary.balance,
              detail: 'Efetivado: ${Money.format(summary.settledBalance)}',
              icon: Icons.account_balance_wallet_outlined,
              primary: true,
            ),
            BalanceCard(
              label: 'Receitas do mês',
              value: summary.income,
              detail: 'Entradas registradas',
              icon: Icons.south_west,
              primary: false,
            ),
            BalanceCard(
              label: 'Despesas do mês',
              value: summary.expenses,
              detail: 'Pendentes: ${Money.format(summary.pending)}',
              icon: Icons.north_east,
              primary: false,
              expense: true,
            ),
          ];
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: c.maxWidth >= 700
                        ? (c.maxWidth - 32) / 3
                        : c.maxWidth,
                    child: card,
                  ),
                )
                .toList(),
          );
        },
      ),
      const SizedBox(height: 24),
      if (controller.entries.isEmpty && !controller.busy)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.savings_outlined, size: 48, color: ink),
                const SizedBox(height: 16),
                Text(
                  'Seu dinheiro, com clareza.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Comece com um lançamento ou explore dados fictícios.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: controller.categories.isEmpty
                      ? () => controller.perform(
                          () => widget.repository.loadDemo(controller.month),
                        )
                      : null,
                  child: const Text('Experimentar com exemplos'),
                ),
              ],
            ),
          ),
        ),
      if (controller.entries.isNotEmpty) ...[
        Insights(summary: summary, month: controller.month),
        const SizedBox(height: 28),
      ],
      const SizedBox(height: 8),
      Text('Lançamentos', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text(
        'Todos os valores do mês, incluindo os pendentes.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              key: const Key('search'),
              onChanged: (text) => setState(() => query = text),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar lançamento ou categoria',
                semanticCounterText: 'Buscar lançamentos',
              ),
            ),
          ),
          ...['Todos', 'Receitas', 'Despesas', 'Pendentes'].map(
            (label) => ChoiceChip(
              label: Text(label),
              selected: filter == label,
              onSelected: (_) => setState(() => filter = label),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (entries.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'Nenhum lançamento encontrado neste mês.',
            textAlign: TextAlign.center,
          ),
        )
      else
        Card(
          child: Column(
            children: [
              for (final entry in entries)
                EntryTile(
                  entry: entry,
                  onEdit: () => editEntry(entry),
                  onDelete: () => delete(
                    '“${entry.description}” será removido permanentemente.',
                    () => widget.repository.deleteEntry(entry.id!),
                  ),
                ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _categories() => [
    const Text(
      'Categorias guardam nome, ícone e cor. Lançamentos mantêm o histórico mesmo após editar ou excluir uma categoria.',
      style: TextStyle(color: muted),
    ),
    const SizedBox(height: 24),
    if (controller.categories.isEmpty)
      const Padding(
        padding: EdgeInsets.all(36),
        child: Text(
          'Ainda não há categorias. Crie a primeira para organizar seus lançamentos.',
        ),
      ),
    Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final c in controller.categories)
          SizedBox(
            width: 310,
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CategoryAvatar(category: c),
                title: Text(c.name),
                subtitle: const Text('Categoria pessoal'),
                onTap: () => editCategory(c),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Ações de ${c.name}',
                  onSelected: (action) => action == 'edit'
                      ? editCategory(c)
                      : delete(
                          'Excluir “${c.name}”? O histórico dos lançamentos será preservado.',
                          () => widget.repository.deleteCategory(c.id!),
                        ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  ];
}

class EntryTile extends StatelessWidget {
  final Entry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const EntryTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact =
          constraints.maxWidth < 600 ||
          MediaQuery.textScalerOf(context).scale(14) > 18;
      final amount = Text(
        '${entry.kind == EntryKind.expense ? '−' : '+'} ${Money.format(entry.cents)}',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: entry.kind == EntryKind.expense ? expenseColor : ink,
        ),
      );
      final menu = PopupMenuButton<String>(
        tooltip: 'Ações de ${entry.description}',
        onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Editar')),
          PopupMenuItem(value: 'delete', child: Text('Excluir')),
        ],
      );
      return Semantics(
        button: true,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryAvatar(category: entry.category),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${entry.category?.name ?? 'Sem categoria'} · ${dateText(entry.date)}${entry.pending ? ' · Pendente' : ''}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      if (compact) ...[const SizedBox(height: 10), amount],
                    ],
                  ),
                ),
                if (!compact)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: amount,
                  ),
                menu,
              ],
            ),
          ),
        ),
      );
    },
  );
}
