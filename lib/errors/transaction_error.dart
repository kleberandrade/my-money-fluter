abstract class TransactionError implements Exception {
  String message;

  @override
  String toString() {
    return message;
  }
}

class TransactionRepositoryError extends TransactionError {
  TransactionRepositoryError(String message) {
    this.message = message;
  }
}
