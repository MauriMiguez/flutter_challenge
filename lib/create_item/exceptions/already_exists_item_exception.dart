class AlreadyExistsItemException implements Exception {
  final String message;
  const AlreadyExistsItemException([
    this.message = 'Item name already exists',
  ]);
}