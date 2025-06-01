import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('AcademiTrack')),
      body: ListView.builder(
        itemCount: projectProvider.projects.length,
        itemBuilder: (context, index) {
          final project = projectProvider.projects[index];
          return ProjectCard(project: project);
        },
      ),
    );
  }
}
