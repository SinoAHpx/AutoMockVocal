class IncompleteConfigException implements Exception {
  String message;

  IncompleteConfigException({required this.message});
}
