import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/priority.dart';
import 'package:todo_app/widgets/summary_bar.dart';
import 'package:todo_app/widgets/add_todo_menu.dart';
import 'package:todo_app/widgets/tab_content.dart';
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

  void _onReorderItem(int oldIndex, int newIndex, String oldID, String newID) {
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

  List<Todo> _currentTodos(int index) {
    switch (index) {
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
                TabContent(
                  todos: _currentTodos(0),
                  emptyMessage: 'No Todos Yet\nAdd One Now',
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
                ),
                TabContent(
                  todos: _currentTodos(1),
                  emptyMessage: 'No Todos Remaining\nYahooo',
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
                ),
                TabContent(
                  todos: _currentTodos(2),
                  emptyMessage: 'No Todos Done Yet',
                  toggleTodo: _toggleTodo,
                  removeTodo: _removeTodo,
                  onReorderItem: _onReorderItem,
                  onTap: _onTap,
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