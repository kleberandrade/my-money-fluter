import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../data/ledger_repository.dart';
import '../domain/ledger.dart';

class LedgerController extends ChangeNotifier {
  final LedgerRepository repository;
  LedgerController(this.repository);
  List<Entry> entries = [];
  List<Category> categories = [];
  bool busy = false;
  String? error;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  MonthSummary get summary => MonthSummary(entries, month);
  Future<void> refresh() => perform(() async {});
  Future<void> perform(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      entries = await repository.readEntries();
      categories = await repository.readCategories();
    } catch (e) {
      error = e is FormatException
          ? e.message
          : 'Não foi possível acessar os dados. Tente novamente. Seus registros não foram apagados.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void moveMonth(int offset) {
    month = DateTime(month.year, month.month + offset);
    notifyListeners();
  }
}
