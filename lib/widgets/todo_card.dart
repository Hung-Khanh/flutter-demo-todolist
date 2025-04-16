import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/time_formatter.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggleTimer;
  final Function(String) onResetTimer;
  final Function(String, bool) onStatusChange;
  final Function(String) onDelete;
  final Function(Todo) onEdit;
  
  const TodoCard({
    Key? key,
    required this.todo,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onStatusChange,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      // Add color indication for overdue tasks
      color: todo.isOverdue ? Colors.red.shade50 : null,
      child: InkWell(
        onTap: () => onEdit(todo),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: isMobile ? 0.9 : 1.0,
                    child: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (value) {
                        onStatusChange(todo.id, value ?? false);
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        if (todo.description.isNotEmpty) ...[
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            todo.description,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: isMobile ? 12 : 14,
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: isMobile ? 32 : 40, top: isMobile ? 4 : 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          TimeFormatter.formatDate(todo.createdAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            onEdit(todo);
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            onDelete(todo.id);
                          },
                        ),
                      ],
                    ),
                    // Deadline section
                    if (todo.deadline != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 14,
                            color: todo.isOverdue 
                              ? Colors.red 
                              : (todo.isDueSoon ? Colors.orange : Colors.blue),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Due: ${TimeFormatter.formatDate(todo.deadline!)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: todo.isOverdue || todo.isDueSoon 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                              color: todo.isOverdue 
                                ? Colors.red 
                                : (todo.isDueSoon ? Colors.orange : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Timer section
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: todo.isTimerRunning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          TimeFormatter.formatTime(todo.timeSpentInSeconds),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: todo.isTimerRunning ? FontWeight.bold : FontWeight.normal,
                            color: todo.isTimerRunning ? Colors.green : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (!todo.isCompleted) ...[
                          IconButton(
                            icon: Icon(
                              todo.isTimerRunning ? Icons.pause : Icons.play_arrow,
                              color: todo.isTimerRunning ? Colors.red : Colors.green,
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              onToggleTimer(todo.id);
                            },
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              onResetTimer(todo.id);
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 