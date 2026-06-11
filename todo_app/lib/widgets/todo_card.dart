import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';

class TodoCard extends StatelessWidget {
  final int index;
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(Todo) _onTap;

  const TodoCard({
    super.key,
    required this.index,
    required this._todos,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(_todos[index].id),
      margin: EdgeInsets.all(8.0),

      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _todos[index].priority.color,
              ),
            ),
            Checkbox(
              value: _todos[index].isDone,
              onChanged: (_) {
                _toggleTodo(_todos[index].id);
              },
            ),
          ],
        ),
        title: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 15,
            decoration: _todos[index].isDone
                ? TextDecoration.lineThrough
                : null,
            color: _todos[index].isDone
                ? Colors.grey
                : Theme.of(context).colorScheme.onSurface,
          ),
          child: Text(_todos[index].text),
        ),
        subtitle: Text(
          _todos[index].priority.label,
          style: TextStyle(fontSize: 11, color: _todos[index].priority.color),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            _removeTodo(_todos[index].id);
          },
        ),
        minVerticalPadding: 12,
        onTap: () => _onTap(_todos[index]),
      ),
    );
  }
}