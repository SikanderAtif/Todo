import 'package:flutter/material.dart';
import 'package:todo_app/models/priority.dart';

class AddTodoMenu extends StatefulWidget {
  final TextEditingController _controller;
  final void Function(Priority) _submit;

  const AddTodoMenu({
    super.key,
    required this._controller,
    required this._submit,
  });

  @override
  State<AddTodoMenu> createState() => _AddTodoMenuState();
}

class _AddTodoMenuState extends State<AddTodoMenu> {
  Priority _selectedPriority = Priority.medium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Todo',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 16),
          TextField(
            controller: widget._controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'What needs to be done',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => widget._submit(_selectedPriority),
          ),
          SizedBox(height: 16),
          Text('Priority', style: TextStyle(fontSize: 15, color: Colors.grey)),
          SizedBox(height: 8),
          Row(
            children: Priority.values.map((p) {
              final isSelected = _selectedPriority == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(p.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPriority = p),
                  selectedColor: p.color.withOpacity(0.2),
                  checkmarkColor: p.color,
                  side: BorderSide(color: isSelected ? p.color : Colors.grey),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget._submit(_selectedPriority);
                  },
                  style: ButtonStyle(
                    alignment: Alignment(0, 0),
                    shape: WidgetStateProperty.resolveWith<OutlinedBorder>((
                      Set<WidgetState> states,
                    ) {
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      );
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.hovered)) {
                        return Colors.grey;
                      }

                      return Colors.white;
                    }),
                  ),
                  child: Text(
                    'Add Todo',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}