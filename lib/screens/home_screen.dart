import 'package:flutter/material.dart';
import 'dart:async';
import '../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/todo_dialog.dart';
import '../widgets/kanban_column.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Local mock data for demo purposes
  final List<Todo> _todos = [
    Todo(
      id: '1',
      title: 'Complete Project Presentation',
      description: 'Finalize slides and practice delivery for client meeting',
      isCompleted: false,
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      deadline: DateTime.now().add(const Duration(days: 2)),
    ),
    Todo(
      id: '2',
      title: 'Weekly Team Meeting',
      description: 'Discuss project timeline and resource allocation',
      isCompleted: true,
      status: 'Done',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Todo(
      id: '3',
      title: 'Research New Features',
      description: 'Look into implementing dark mode and offline capabilities',
      isCompleted: false,
      status: 'To Do',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
  ];
  
  bool _isLoading = false;
  
  // Status options for kanban board
  final List<String> _statusColumns = ['To Do', 'In Progress', 'Done'];
  
  // Timer for tracking time spent on tasks
  Timer? _taskTimer;
  
  @override
  void initState() {
    super.initState();
    // Start a timer that updates running task timers every second
    _taskTimer = Timer.periodic(const Duration(seconds: 1), _updateRunningTimers);
  }
  
  @override
  void dispose() {
    _taskTimer?.cancel();
    super.dispose();
  }
  
  void _updateRunningTimers(Timer timer) {
    bool hasUpdates = false;
    
    for (int i = 0; i < _todos.length; i++) {
      if (_todos[i].isTimerRunning) {
        _todos[i] = _todos[i].copyWith(
          timeSpentInSeconds: _todos[i].timeSpentInSeconds + 1
        );
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      setState(() {});
    }
  }
  
  // Toggle timer for a specific todo
  void _toggleTimer(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          isTimerRunning: !_todos[index].isTimerRunning
        );
      }
    });
  }
  
  // Reset timer for a specific todo
  void _resetTimer(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          timeSpentInSeconds: 0,
          isTimerRunning: false
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              // Simulate loading
              Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: _isLoading
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading tasks...'),
              ],
            ),
          )
        : _buildKanbanBoard(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildKanbanBoard() {
    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notes, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No tasks yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Add a new task to get started!'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddTodoDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use column layout for mobile screens (width < 600)
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _statusColumns.map((status) {
                  // Filter todos by status
                  final statusTodos = _todos.where((todo) => todo.status == status).toList();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: KanbanColumn(
                      status: status,
                      todos: statusTodos,
                      columnColor: _getColumnColor(status),
                      onAccept: (Todo todo) => _updateTodoStatus(todo, status),
                      buildDraggableTodoCard: _buildDraggableTodoCard,
                    ),
                  );
                }).toList(),
              );
            }
            // Use original row layout for larger screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _statusColumns.map((status) {
                // Filter todos by status
                final statusTodos = _todos.where((todo) => todo.status == status).toList();
                
                return Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: KanbanColumn(
                      status: status,
                      todos: statusTodos,
                      columnColor: _getColumnColor(status),
                      onAccept: (Todo todo) => _updateTodoStatus(todo, status),
                      buildDraggableTodoCard: _buildDraggableTodoCard,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
  
  Color _getColumnColor(String status) {
    switch (status) {
      case 'To Do':
        return Colors.grey.shade700;
      case 'In Progress':
        return Colors.blue.shade700;
      case 'Done':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
  
  Widget _buildDraggableTodoCard(Todo todo) {
    return Draggable<Todo>(
      data: todo,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: MediaQuery.of(context).size.width < 600 
              ? MediaQuery.of(context).size.width * 0.75 
              : MediaQuery.of(context).size.width * 0.25,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            todo.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: TodoCard(
          todo: todo,
          onToggleTimer: _toggleTimer,
          onResetTimer: _resetTimer,
          onStatusChange: _updateTodoCompletionStatus,
          onDelete: _deleteTodo,
          onEdit: _showEditTodoDialog,
        ),
      ),
      child: TodoCard(
        todo: todo,
        onToggleTimer: _toggleTimer,
        onResetTimer: _resetTimer,
        onStatusChange: _updateTodoCompletionStatus,
        onDelete: _deleteTodo,
        onEdit: _showEditTodoDialog,
      ),
    );
  }

  // Local operations without Firebase
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateTodoCompletionStatus(String id, bool isCompleted) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        // If completing task, move to Done status
        String status = _todos[index].status;
        if (isCompleted && status != 'Done') {
          status = 'Done';
        } 
        // If uncompleting a Done task, move to In Progress
        else if (!isCompleted && status == 'Done') {
          status = 'In Progress';
        }
        
        _todos[index] = _todos[index].copyWith(
          isCompleted: isCompleted,
          status: status,
        );
      }
    });
  }

  void _updateTodoStatus(Todo todo, String newStatus) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        bool isCompleted = newStatus == 'Done' ? true : todo.isCompleted;
        _todos[index] = _todos[index].copyWith(
          status: newStatus,
          isCompleted: isCompleted,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${todo.title}" to $newStatus'),
            duration: const Duration(seconds: 1),
            backgroundColor: _getColumnColor(newStatus),
          ),
        );
      }
    });
  }

  void _addTodo(
    String id,
    String title,
    String description,
    String status,
    {int? timeSpent, 
    DateTime? deadline}
  ) {
    final newTodo = Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: status == 'Done',
      status: status,
      createdAt: DateTime.now(),
      timeSpentInSeconds: timeSpent ?? 0,
      deadline: deadline,
    );
    
    setState(() {
      _todos.add(newTodo);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateTodo(
    String id,
    String title,
    String description,
    String status,
    bool isCompleted,
    {int? timeSpent,
    DateTime? deadline}
  ) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        // If completing a task, stop the timer
        bool isTimerRunning = _todos[index].isTimerRunning;
        if (isCompleted && isTimerRunning) {
          isTimerRunning = false;
        }
        
        _todos[index] = _todos[index].copyWith(
          title: title,
          description: description,
          status: status,
          isCompleted: isCompleted || status == 'Done', // If status is Done, mark as completed
          isTimerRunning: isTimerRunning,
          timeSpentInSeconds: timeSpent,
          deadline: deadline,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Update add todo dialog
  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TodoDialog(
          statusOptions: _statusColumns,
          onSave: (id, title, description, status, {isCompleted, timeSpent, deadline}) {
            _addTodo(
              id, 
              title, 
              description, 
              status,
              timeSpent: timeSpent,
              deadline: deadline,
            );
          },
        );
      },
    );
  }

  // Add edit todo dialog
  void _showEditTodoDialog(Todo todo) {
    showDialog(
      context: context,
      builder: (context) {
        return TodoDialog(
          todo: todo,
          statusOptions: _statusColumns,
          onSave: (id, title, description, status, {isCompleted, timeSpent, deadline}) {
            _updateTodo(
              id,
              title,
              description,
              status,
              isCompleted ?? status == 'Done', // isCompleted based on status
              timeSpent: timeSpent,
              deadline: deadline,
            );
          },
        );
      },
    );
  }
} 