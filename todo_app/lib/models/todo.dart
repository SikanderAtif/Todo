import "priority.dart";

class Todo {
  final String id;
  String text;
  Priority priority;
  bool isDone;
  final DateTime dateCreated;

  Todo({
    required this.id,
    required this.text,
    required this.priority,
    this.isDone = false,
    DateTime? dateCreated,
  }) : dateCreated = dateCreated ?? DateTime.now();

  static String generateID() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  void toggle() => isDone = !isDone;
}
