import 'package:flutter/material.dart';
import '../models/todo.dart';

class KanbanColumn extends StatelessWidget {
  final String status;
  final List<Todo> todos;
  final Color columnColor;
  final Function(Todo) onAccept;
  final Function(Todo) buildDraggableTodoCard;

  const KanbanColumn({
    Key? key,
    required this.status,
    required this.todos,
    required this.columnColor,
    required this.onAccept,
    required this.buildDraggableTodoCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column header
        _buildColumnHeader(),
        const SizedBox(height: 8),
        // Drag target area for this column
        DragTarget<Todo>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                color: candidateData.isNotEmpty 
                  ? Colors.grey.shade200
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: candidateData.isNotEmpty 
                    ? Colors.grey.shade400
                    : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Add tasks to this column
                  ...todos.map((todo) => buildDraggableTodoCard(todo)),
                  // Empty space for drop target when empty
                  if (todos.isEmpty)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Drop task here',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          onAccept: onAccept,
        ),
      ],
    );
  }

  Widget _buildColumnHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: columnColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${todos.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 