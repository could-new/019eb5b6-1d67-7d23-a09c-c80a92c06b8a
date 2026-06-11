import 'package:flutter/material.dart';

import 'package:couldai_user_app/integrations/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.ensureInitialized();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待办事项',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TodoListScreen(),
      },
    );
  }
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _todos = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodo(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _todos.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
      ));
    });
    _textController.clear();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加新任务'),
          content: TextField(
            controller: _textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入任务内容...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _addTodo(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _textController.clear();
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                _addTodo(_textController.text);
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 针对大屏幕设备限制最大宽度，使界面在大屏上也不会过宽
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _todos.isEmpty
                ? const Center(
                    child: Text(
                      '太棒了！所有任务已完成。',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (value) => _toggleTodo(index),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              color: todo.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteTodo(index),
                            tooltip: '删除',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('新任务'),
      ),
    );
  }
}
