class AlreadyExistsCategoryException implements Exception {
  final String message;
  const AlreadyExistsCategoryException([
    this.message = 'Category name already exists',
  ]);
}