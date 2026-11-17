import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/ledger.dart';
import 'theme.dart';

class BalanceCard extends StatelessWidget {
  final String label, detail;
  final int value;
  final IconData icon;
  final bool primary, expense;
  const BalanceCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.primary,
    this.expense = false,
  });
  @override
  Widget build(BuildContext context) => Card(
    color: primary ? ink : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: primary ? const Color(0xffd2e4d8) : muted,
                  ),
                ),
              ),
              Icon(
                icon,
                color: primary
                    ? const Color(0xffd2e4d8)
                    : expense
                    ? expenseColor
                    : ink,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Money.format(value),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
                color: primary ? Colors.white : ink,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            style: TextStyle(
              color: primary ? const Color(0xffd2e4d8) : muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

class Insights extends StatelessWidget {
  final MonthSummary summary;
  final DateTime month;
  const Insights({super.key, required this.summary, required this.month});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final chart = Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O ritmo das despesas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Valores por dia · inclui pendências',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 155,
                child: Semantics(
                  label:
                      'Despesas diárias: ${summary.dailyExpenses.entries.map((e) => 'dia ${e.key}: ${Money.format(e.value)}').join('; ')}',
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _ExpensePainter(
                      summary.dailyExpenses,
                      DateTime(month.year, month.month + 1, 0).day,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'DIA 01',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'AO LONGO DO MÊS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'FIM DO MÊS',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      final groups = summary.categoryExpenses.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final categories = Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para onde vai',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Despesas por categoria',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              if (groups.isEmpty) const Text('Sem despesas neste mês.'),
              for (final group in groups.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text(group.key),
                            Text(
                              Money.format(group.value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: group.value / summary.expenses,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(5),
                        backgroundColor: canvas,
                        color: ink,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
      if (constraints.maxWidth < 800) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [chart, const SizedBox(height: 16), categories],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: chart),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: categories),
        ],
      );
    },
  );
}

class _ExpensePainter extends CustomPainter {
  final Map<int, int> values;
  final int days;
  _ExpensePainter(this.values, this.days);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xffe4e9e3)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final maximum = values.values.fold(1, math.max);
    final step = size.width / days;
    final paint = Paint()..color = const Color(0xff558171);
    for (var day = 1; day <= days; day++) {
      final height = (values[day] ?? 0) / maximum * (size.height - 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (day - 1) * step + 2,
            size.height - height,
            math.max(2, step - 4),
            height,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ExpensePainter oldDelegate) => true;
}
