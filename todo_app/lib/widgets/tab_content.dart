import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/widgets/dismissible_list.dart';
import 'package:todo_app/widgets/empty_state.dart';

class TabContent extends StatelessWidget {
  final List<Todo> _todos;
  final String _emptyMessage;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int, String, String) _onReorderItem;
  final void Function(Todo) _onTap;

  const TabContent({
    super.key,
    required this._todos,
    required this._emptyMessage,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onReorderItem,
    required this._onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _todos.isEmpty
        ? EmptyState(message: _emptyMessage)
        : DismissibleItem(
            todos: _todos,
            toggleTodo: _toggleTodo,
            removeTodo: _removeTodo,
            onReorderItem: _onReorderItem,
            onTap: _onTap,
          );
  }
}