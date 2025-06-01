import 'package:flutter/material.dart';
import '../models/project.dart';
import '../screens/project_detail_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(project.title),
        subtitle: Text(
          '${project.startDate.toLocal()} - ${project.endDate.toLocal()}',
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
      ),
    );
  }
}
