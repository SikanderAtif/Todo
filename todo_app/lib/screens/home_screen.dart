import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/priority.dart';
import 'package:todo_app/widgets/dismissible_list.dart';
import 'package:todo_app/widgets/summary_bar.dart';
import 'package:todo_app/widgets/add_todo_menu.dart';
import 'package:todo_app/widgets/empty_state.dart';
import 'details_screen.dart';
import 'stats_screen.dart';

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
              ? SummaryBar(
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