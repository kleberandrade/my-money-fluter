import 'package:intl/intl.dart';

class DateHelper {
  static String format(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
