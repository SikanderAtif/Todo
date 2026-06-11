import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/priority.dart';

class StatsScreen extends StatefulWidget {
  final List<Todo> _todos;
  const StatsScreen({super.key, required this._todos});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final String title = 'Stats';
  int get _total => widget._todos.length;
  int get _done => (widget._todos.where((t) => t.isDone)).length;
  int get _remaining => (widget._todos.where((t) => !t.isDone)).length;
  int get _high =>
      (widget._todos.where((t) => t.priority == Priority.high)).length;
  int get _medium =>
      (widget._todos.where((t) => t.priority == Priority.medium)).length;
  int get _low =>
      (widget._todos.where((t) => t.priority == Priority.low)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 12),
            Text(
              'Completion',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Todos',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_total ',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_done ',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_remaining ',
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: _done == 0 ? 0.0 : _done / _total,
              ),
              duration: Duration(milliseconds: 400),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation(
                    _done == _total && _total != 0
                        ? Colors.green
                        : Colors.indigo,
                  ),
                );
              },
            ),
            Text(
              '${(_done / _total) * 100}% complete',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            SizedBox(height: 22),
            Text(
              'By Priority',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'High',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_high ',
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medium',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_medium ',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Text(
                    ' $_low ',
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
