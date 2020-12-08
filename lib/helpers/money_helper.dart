import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';

class MoneyHelper {
  static final format = NumberFormat("#.##0,00", "pt_BR");

  static final _controller = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 2,
  );

  static String parse(double value) {
    _controller.updateValue(value);
    return _controller.text;
  }
}
