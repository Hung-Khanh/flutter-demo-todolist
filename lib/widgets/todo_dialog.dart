import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../utils/time_formatter.dart';

class TodoDialog extends StatefulWidget {
  final Todo? todo;
  final List<String> statusOptions;
  final Function(String, String, String, String, {bool? isCompleted, int? timeSpent, DateTime? deadline}) onSave;

  const TodoDialog({
    Key? key,
    this.todo,
    required this.statusOptions,
    required this.onSave,
  }) : super(key: key);

  @override
  _TodoDialogState createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  late bool _isCompleted;
  late int _timeSpent;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedStatus = widget.todo?.status ?? widget.statusOptions.first;
    _isCompleted = widget.todo?.isCompleted ?? false;
    _timeSpent = widget.todo?.timeSpentInSeconds ?? 0;
    _selectedDeadline = widget.todo?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
      title: Row(
        children: [
          Icon(widget.todo == null ? Icons.add_task : Icons.edit, color: const Color(0xFF616161)),
          const SizedBox(width: 8),
          Text(widget.todo == null ? 'Add New Task' : 'Edit Task'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              items: widget.statusOptions
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  // Update isCompleted when status is changed to Done
                  if (value == 'Done' && !_isCompleted) {
                    _isCompleted = true;
                  } else if (value != 'Done' && _isCompleted && widget.todo?.status == 'Done') {
                    _isCompleted = false;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as completed'),
              value: _isCompleted,
              activeColor: const Color(0xFF757575),
              onChanged: (bool value) {
                setState(() {
                  _isCompleted = value;
                  // Update status when isCompleted is changed
                  if (value && _selectedStatus != 'Done') {
                    _selectedStatus = 'Done';
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            // Deadline selector
            InkWell(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  
                  if (pickedTime != null) {
                    setState(() {
                      _selectedDeadline = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: _selectedDeadline == null
                    ? const Text('Set a deadline', style: TextStyle(color: Colors.grey))
                    : Text(
                        TimeFormatter.formatDateTime(_selectedDeadline!),
                        style: TextStyle(
                          color: _selectedDeadline!.isBefore(DateTime.now()) 
                              ? Colors.red 
                              : Colors.black87,
                        ),
                      ),
              ),
            ),
            if (widget.todo != null) ...[
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Time spent'),
                subtitle: Text(TimeFormatter.formatTime(_timeSpent)),
                contentPadding: EdgeInsets.zero,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.timer_outlined, size: 16),
                      label: const Text('Edit'),
                      onPressed: () {
                        _showTimeEditDialog(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _timeSpent = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onSave(
                widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                _titleController.text,
                _descriptionController.text,
                _selectedStatus,
                isCompleted: _isCompleted,
                timeSpent: _timeSpent,
                deadline: _selectedDeadline,
              );
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF757575),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.todo == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _showTimeEditDialog(BuildContext context) {
    final TextEditingController hoursController = TextEditingController(
        text: (_timeSpent ~/ 3600).toString());
    final TextEditingController minutesController = TextEditingController(
        text: ((_timeSpent % 3600) ~/ 60).toString());
    final TextEditingController secondsController = TextEditingController(
        text: (_timeSpent % 60).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Time Spent'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Hrs',
                  ),
                ),
              ),
              const Text(' : '),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                  ),
                ),
              ),
              const Text(' : '),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Sec',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Calculate total seconds
                final hours = int.tryParse(hoursController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;
                
                final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
                setState(() {
                  _timeSpent = totalSeconds;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
} 