import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';

class SummaryBar extends StatelessWidget {
  final List<Todo> _todos;
  final int _total;
  final int _done;
  final int _active;

  const SummaryBar({
    super.key,
    required this._todos,
    required this._total,
    required this._done,
    required this._active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '     $_active remaining',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            Text(
              '$_done/$_total done     ',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: _todos.isEmpty ? 0.0 : _done / _total,
          ),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                _done == _total && _total != 0 ? Colors.green : Colors.indigo,
              ),
            );
          },
        ),
      ],
    );
  }
}