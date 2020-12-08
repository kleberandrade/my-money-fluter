abstract class CategoryError implements Exception {
  String message;

  @override
  String toString() {
    return message;
  }
}

class CategoryRepositoryError extends CategoryError {
  CategoryRepositoryError(String message) {
    this.message = message;
  }
}
