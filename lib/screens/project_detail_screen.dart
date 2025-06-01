import 'package:academitrack/screens/add_task_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';

import '../widgets/task_tile.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Dashboard Placeholder')));
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  ProjectDetailScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasksByProject(project.id! as String);

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(task: task);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
