import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(task.title),
      subtitle: Text(task.dueDate.toLocal().toString()),
      value: task.isCompleted,
      onChanged: (bool? value) {},
    );
  }
}
