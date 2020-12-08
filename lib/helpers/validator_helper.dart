class ValidatorHelper {
  static String isValidText(String text) {
    if (text.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }
}
