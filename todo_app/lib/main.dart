import 'package:flutter/material.dart';
import "models/priority.dart";
import "models/todo.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(title: 'My Todos'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  final List<Todo> _todos = [];
  static const _tabs = ['All', 'Active', 'Done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _clearTextEditor() {
    _controller.clear();
  }

  void _toggleTodo(String id) {
    setState(() {
      _todos.firstWhere((t) => t.id == id).toggle();
    });
  }

  void _submit(Priority priority) {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(Todo(id: Todo.generateID(), text: text, priority: priority));
      _clearTextEditor();
    });
    Navigator.pop(context);
  }

  void _removeTodo(String id) {
    final int undoIndex = _todos.indexWhere((t) => t.id == id);
    final Todo undoItem = _todos.removeAt(undoIndex);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${undoItem.text} deleted'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.blue,
          onPressed: () {
            setState(() {
              _todos.insert(undoIndex, undoItem);
            });
          },
        ),
      ),
    );
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    String oldID = _currentTodos[oldIndex].id;
    String newID = _currentTodos[newIndex].id;
    int oIndex = _todos.indexWhere((t) => t.id == oldID);

    setState(() {
      final item = _todos.removeAt(oIndex);
      int nIndex = _todos.indexWhere((t) => t.id == newID);
      if (oldIndex < newIndex) nIndex += 1;
      _todos.insert(nIndex, item);
    });
  }

  void _onTap(Todo todo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsScreen(todo: todo)),
    );

    setState(() {});
  }

  void _showAddTodoMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AddTodoMenu(controller: _controller, submit: _submit);
          },
        );
      },
    );
  }

  List<Todo> get _activeTodos => _todos.where((t) => !t.isDone).toList();
  List<Todo> get _doneTodos => _todos.where((t) => t.isDone).toList();
  int get _active => _activeTodos.length;
  int get _done => _doneTodos.length;
  int get _total => _todos.length;

  List<Todo> get _currentTodos {
    switch (_tabController.index) {
      case 1:
        return _activeTodos;
      case 2:
        return _doneTodos;
      default:
        return _todos;
    }
  }

  void _clearDone() {
    setState(() {
      _todos.removeWhere((t) => t.isDone == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            tooltip: 'Stats Page',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatsScreen(todos: _todos),
              ),
            ),
          ),
          if (_doneTodos.isNotEmpty)
            TextButton(
              onPressed: _clearDone,
              child: Row(
                children: [Icon(Icons.delete), Text('Clear ($_done)')],
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          _doneTodos.isNotEmpty
              ? _SummaryBar(
                  todos: _todos,
                  total: _total,
                  done: _done,
                  active: _active,
                )
              : SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllTab(
                  todos: _currentTodos,
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
                  emptyMessage: 'No Todos Yet\nAdd One Now',
                ),
                _ActiveTab(
                  todos: _currentTodos,
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
                  emptyMessage: 'No Todos Remaining\nYahooo',
                ),
                _DoneTab(
                  todos: _currentTodos,
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
                  emptyMessage: 'No Todos Done Yet',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoMenu,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
    );
  }
}

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

class _AllTab extends StatelessWidget {
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int) _onReorderItem;
  final void Function(Todo) _onTap;
  final String _emptyMessage;

  const _AllTab({
    required this._todos,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onReorderItem,
    required this._onTap,
    required this._emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _todos.isEmpty
        ? _EmptyState(message: _emptyMessage)
        : _DismissibleItem(
            todos: _todos,
            toggleTodo: _toggleTodo,
            removeTodo: _removeTodo,
            onReorderItem: _onReorderItem,
            onTap: _onTap,
          );
  }
}

class _ActiveTab extends StatelessWidget {
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int) _onReorderItem;
  final void Function(Todo) _onTap;
  final String _emptyMessage;

  const _ActiveTab({
    required this._todos,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onReorderItem,
    required this._onTap,
    required this._emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _todos.isEmpty
        ? _EmptyState(message: _emptyMessage)
        : _DismissibleItem(
            todos: _todos,
            toggleTodo: _toggleTodo,
            removeTodo: _removeTodo,
            onReorderItem: _onReorderItem,
            onTap: _onTap,
          );
  }
}

class _DoneTab extends StatelessWidget {
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int) _onReorderItem;
  final void Function(Todo) _onTap;
  final String _emptyMessage;

  const _DoneTab({
    required this._todos,
    required this._toggleTodo,
    required this._removeTodo,
    required this._onReorderItem,
    required this._onTap,
    required this._emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return _todos.isEmpty
        ? _EmptyState(message: _emptyMessage)
        : _DismissibleItem(
            todos: _todos,
            toggleTodo: _toggleTodo,
            removeTodo: _removeTodo,
            onReorderItem: _onReorderItem,
            onTap: _onTap,
          );
  }
}

class _DismissibleItem extends StatelessWidget {
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(int, int) _onReorderItem;
  final void Function(Todo) _onTap;

  const _DismissibleItem({
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
          child: _TodoCard(
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

class _TodoCard extends StatelessWidget {
  final int index;
  final List<Todo> _todos;
  final void Function(String) _toggleTodo;
  final void Function(String) _removeTodo;
  final void Function(Todo) _onTap;

  const _TodoCard({
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

class _SummaryBar extends StatelessWidget {
  final List<Todo> _todos;
  final int _total;
  final int _done;
  final int _active;

  const _SummaryBar({
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

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey),
          Text(
            message,
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/*
class PriorityButtons extends StatefulWidget {
  const PriorityButtons({super.key});

  @override
  State<PriorityButtons> createState() => _PriorityButtonsState();
}

class _PriorityButtonsState extends State<PriorityButtons> {
  final List<bool> _isSelected = [false, true, false];
  final List<Priority> _priority = [
    Priority.low,
    Priority.medium,
    Priority.high,
  ];

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: _isSelected,
      onPressed: (index) => setState(() {
        final oldIndex = _isSelected.indexWhere((element) => element == true);
        _isSelected[oldIndex] = false;
        _isSelected[index] = true;
      }),
      // Color configuration
      color: Colors.blueGrey,
      selectedColor: Theme.of(context).colorScheme.onSurface,
      fillColor: _priority[_isSelected.indexWhere((i) => i == true)].color,
      // Border configuration
      borderWidth: 2,
      borderColor: Colors.blue.withOpacity(0.5),
      selectedBorderColor:
          _priority[_isSelected.indexWhere((i) => i == true)].border,
      borderRadius: BorderRadius.circular(8),

      constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
      children: [
        Text(Priority.low.label),
        Text(Priority.medium.label),
        Text(Priority.high.label),
      ],
    );
  }
}
*/
