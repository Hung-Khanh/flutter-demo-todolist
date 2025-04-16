import 'package:intl/intl.dart';

class TimeFormatter {
  // Format seconds into HH:MM:SS
  static String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    final hoursStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    
    return '$hoursStr$minutesStr:$secondsStr';
  }

  // Format date as dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  // Format date relative to now (Today, Yesterday, etc)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(dateDay).inDays;
    
    if (difference == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
} 