import 'package:flutter/material.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? createdAt;
  final String status;
  final int timeSpentInSeconds;
  final bool isTimerRunning;
  final DateTime? deadline;  // Added deadline field

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.createdAt,
    this.status = 'To Do',
    this.timeSpentInSeconds = 0,
    this.isTimerRunning = false,
    this.deadline,  // New deadline parameter
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    String? status,
    int? timeSpentInSeconds,
    bool? isTimerRunning,
    DateTime? deadline,  // New deadline parameter
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      timeSpentInSeconds: timeSpentInSeconds ?? this.timeSpentInSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      deadline: deadline ?? this.deadline,  // Copy deadline
    );
  }

  // Calculate if a task is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return deadline!.isBefore(DateTime.now());
  }

  // Calculate if a task is due soon (within 24 hours)
  bool get isDueSoon {
    if (deadline == null || isCompleted) return false;
    final difference = deadline!.difference(DateTime.now());
    return difference.inHours > 0 && difference.inHours <= 24;
  }
} 