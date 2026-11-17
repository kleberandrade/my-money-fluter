import 'dart:collection';

/// Values are cents, never localized text or floating point.
abstract final class Money {
  static const maxCents = 999999999999;
  static int parse(String input) {
    final text = input.trim();
    if (!RegExp(r'^(?:\d+|\d{1,3}(?:\.\d{3})+)(?:,\d{1,2})?$').hasMatch(text)) {
      throw const FormatException('Use um valor como 1.234,56');
    }
    final parts = text.replaceAll('.', '').split(',');
    final cents = int.tryParse(
      '${parts[0]}${parts.length == 1 ? '00' : parts[1].padRight(2, '0')}',
    );
    if (cents == null || cents <= 0 || cents > maxCents) {
      throw const FormatException(
        'Informe um valor entre 0,01 e 9.999.999.999,99',
      );
    }
    return cents;
  }

  static String input(int cents) =>
      '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
  static String format(int cents) => formatTotal(BigInt.from(cents));

  static String formatTotal(BigInt cents) {
    final absolute = cents.abs();
    final whole = (absolute ~/ BigInt.from(100)).toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '${cents.isNegative ? '-' : ''}R\$ $whole,${(absolute % BigInt.from(100)).toString().padLeft(2, '0')}';
  }
}

String validName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed.length > 100) {
    throw const FormatException('Use de 1 a 100 caracteres');
  }
  return trimmed;
}

DateTime parseDate(String input) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(input.trim());
  if (match == null) throw const FormatException('Use dd/mm/aaaa');
  final day = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final year = int.parse(match[3]!);
  final date = DateTime(year, month, day);
  if (year < 1900 || year > 2100 || date.day != day || date.month != month) {
    throw const FormatException('Data inválida (1900–2100)');
  }
  return date;
}

String dateText(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class Category {
  final int? id;
  final String name;
  final int icon;
  final int color;
  Category({
    this.id,
    required String name,
    this.icon = 0xe318,
    this.color = 0xff38695e,
  }) : name = validName(name);
  Map<String, Object?> toMap() => {'name': name, 'icon': icon, 'color': color};
  factory Category.fromMap(Map<String, Object?> map, {int? id}) => Category(
    id: id,
    name: map['name'] as String,
    icon: map['icon'] as int? ?? 0xe318,
    color: map['color'] as int? ?? 0xff38695e,
  );
}

enum EntryKind { income, expense }

class Entry {
  final int? id;
  final String description;
  final int cents;
  final DateTime date;
  final bool pending;
  final Category? category;
  final EntryKind kind;
  Entry({
    this.id,
    required String description,
    required this.cents,
    required DateTime date,
    this.pending = false,
    this.category,
    required this.kind,
  }) : description = validName(description),
       date = DateTime(date.year, date.month, date.day) {
    if (cents <= 0 || cents > Money.maxCents) {
      throw const FormatException('Valor inválido');
    }
    if (date.year < 1900 || date.year > 2100) {
      throw const FormatException('Data inválida');
    }
  }
  Map<String, Object?> toMap() => {
    'description': description,
    'amountMinor': cents,
    'dateLocal': dateKey(date),
    'date': date.millisecondsSinceEpoch,
    'isPending': pending,
    'category': category?.toMap(),
    'type': kind.index,
  };
  factory Entry.fromMap(Map<String, Object?> map, {int? id}) {
    final local = map['dateLocal'] as String;
    final parts = local.split('-');
    if (parts.length != 3) {
      throw const FormatException('Data persistida inválida');
    }
    final date = parseDate('${parts[2]}/${parts[1]}/${parts[0]}');
    return Entry(
      id: id,
      description: map['description'] as String,
      cents: map['amountMinor'] as int,
      date: date,
      pending: map['isPending'] as bool? ?? false,
      category: map['category'] == null
          ? null
          : Category.fromMap(Map<String, Object?>.from(map['category'] as Map)),
      kind: EntryKind.values[map['type'] as int],
    );
  }
}

class MonthSummary {
  final List<Entry> entries;
  MonthSummary(Iterable<Entry> all, DateTime month)
    : entries = List.unmodifiable(
        all.where(
          (e) => e.date.year == month.year && e.date.month == month.month,
        ),
      );
  BigInt _total(EntryKind kind) => entries
      .where((e) => e.kind == kind)
      .fold(BigInt.zero, (sum, e) => sum + BigInt.from(e.cents));
  BigInt get income => _total(EntryKind.income);
  BigInt get expenses => _total(EntryKind.expense);
  BigInt get balance => income - expenses;
  BigInt get settledBalance => entries
      .where((e) => !e.pending)
      .fold(
        BigInt.zero,
        (sum, e) =>
            sum + BigInt.from(e.kind == EntryKind.income ? e.cents : -e.cents),
      );
  BigInt get pending => entries
      .where((e) => e.pending)
      .fold(BigInt.zero, (sum, e) => sum + BigInt.from(e.cents));
  Map<int, BigInt> get dailyExpenses {
    final result = SplayTreeMap<int, BigInt>();
    for (final e in entries.where((e) => e.kind == EntryKind.expense)) {
      result.update(
        e.date.day,
        (v) => v + BigInt.from(e.cents),
        ifAbsent: () => BigInt.from(e.cents),
      );
    }
    return result;
  }

  Map<String, BigInt> get categoryExpenses {
    final result = <String, BigInt>{};
    for (final e in entries.where((e) => e.kind == EntryKind.expense)) {
      result.update(
        e.category?.name ?? 'Sem categoria',
        (v) => v + BigInt.from(e.cents),
        ifAbsent: () => BigInt.from(e.cents),
      );
    }
    return result;
  }
}
