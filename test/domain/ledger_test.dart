import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/domain/ledger.dart';

void main() {
  test('Brazilian amounts are parsed as exact cents', () {
    expect(Money.parse('1.234,56'), 123456);
    expect(Money.parse('0,10') + Money.parse('0,20'), 30);
    expect(Money.format(-123456), '-R\$ 1.234,56');
    for (final input in [
      '',
      '0',
      '-1',
      '1.50',
      '1,234',
      'NaN',
      '1e3',
      '1.23,45',
      '9999999999999999',
    ]) {
      expect(() => Money.parse(input), throwsFormatException, reason: input);
    }
  });
  test('domain rejects invalid descriptions, money and dates', () {
    expect(() => Category(name: ' '), throwsFormatException);
    expect(
      () => Entry(
        description: ' ',
        cents: 1,
        date: DateTime(2026),
        kind: EntryKind.expense,
      ),
      throwsFormatException,
    );
    expect(
      () => Entry(
        description: 'Test',
        cents: 0,
        date: DateTime(2026),
        kind: EntryKind.expense,
      ),
      throwsFormatException,
    );
    expect(() => parseDate('31/02/2026'), throwsFormatException);
    expect(parseDate('29/02/2024'), DateTime(2024, 2, 29));
  });
  test(
    'monthly totals use year and month; pending separated; daily expenses sorted',
    () {
      Entry item(
        int cents,
        DateTime date, {
        bool pending = false,
        EntryKind kind = EntryKind.expense,
      }) => Entry(
        description: 'Test',
        cents: cents,
        date: date,
        kind: kind,
        pending: pending,
      );
      final summary = MonthSummary([
        item(1000, DateTime(2026, 11, 3), kind: EntryKind.income),
        item(10, DateTime(2026, 11, 2)),
        item(20, DateTime(2026, 11, 2)),
        item(100, DateTime(2025, 11, 1)),
        item(400, DateTime(2026, 12)),
        item(50, DateTime(2026, 11, 4), pending: true),
      ], DateTime(2026, 11));
      expect(summary.income, BigInt.from(1000));
      expect(summary.expenses, BigInt.from(80));
      expect(summary.balance, BigInt.from(920));
      expect(summary.settledBalance, BigInt.from(970));
      expect(summary.pending, BigInt.from(50));
      expect(summary.dailyExpenses.keys, [2, 4]);
      expect(summary.dailyExpenses[2], BigInt.from(30));
    },
  );
  test(
    'large ledgers aggregate exactly beyond the browser safe-integer range',
    () {
      final item = Entry(
        description: 'Limite',
        cents: Money.maxCents,
        date: DateTime(2026, 11),
        kind: EntryKind.income,
      );
      final summary = MonthSummary(
        List.filled(10001, item),
        DateTime(2026, 11),
      );
      expect(summary.income, BigInt.parse('10000999999989999'));
      expect(Money.formatTotal(summary.income), 'R\$ 100.009.999.999.899,99');
    },
  );
}
