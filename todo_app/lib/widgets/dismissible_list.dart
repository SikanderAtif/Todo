import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'todo_card.dart';

class DismissibleItem extends StatelessWidget {
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int) _onReorderItem;
  final void Function(Todo) _onTap;

  const DismissibleItem({
    super.key,
    required this._todos,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onReorderItem,
    required this._onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(_todos[index].id),
          direction: DismissDirection.endToStart,
          background: _DeleteCard(),
          onDismissed: (_) {
            _removeTodo(_todos[index].id);
          },
          child: TodoCard(
            index: index,
            todos: _todos,
            toggleTodo: _toggleTodo,
            removeTodo: _removeTodo,
            onTap: _onTap,
          ),
        );
      },
      onReorderItem: _onReorderItem,
    );
  }
}

class _DeleteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      child: Row(children: [Expanded(child: Icon(Icons.delete))]),
    );
  }
}