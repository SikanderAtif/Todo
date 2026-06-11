import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/priority.dart';

class DetailsScreen extends StatefulWidget {
  final Todo _todo;
  const DetailsScreen({super.key, required this._todo});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final String title = 'Todo Detail';
  final TextEditingController _controller = TextEditingController();
  late Priority _selectedPriority;
  late bool _isDone;

  @override
  void initState() {
    super.initState();
    _controller.text = widget._todo.text;
    _selectedPriority = widget._todo.priority;
    _isDone = widget._todo.isDone;
  }

  void _saveChanges() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot Enter Empty Task'),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }

    setState(() {
      widget._todo.text = _controller.text;
      widget._todo.priority = _selectedPriority;
      widget._todo.isDone = _isDone;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 22),
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      'Created  ${widget._todo.dateCreated}',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Text(
                  'Task',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  onSubmitted: (_) => _saveChanges(),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: Priority.values.map((p) {
                    final isSelected = _selectedPriority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(p.label),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedPriority = p),
                        selectedColor: p.color.withOpacity(0.2),
                        checkmarkColor: p.color,
                        side: BorderSide(
                          color: isSelected ? p.color : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 22),
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: _isDone ? Text('Completed') : Text('Active'),
                  subtitle: _isDone
                      ? Text('This Todo is done')
                      : Text('Still in Progress'),
                  value: _isDone,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isDone = newValue;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                verticalDirection: VerticalDirection.down,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ButtonStyle(
                            alignment: Alignment(0, 0),
                            shape:
                                WidgetStateProperty.resolveWith<OutlinedBorder>(
                                  (Set<WidgetState> states) {
                                    return RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    );
                                  },
                                ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
